use serde::{Deserialize, Serialize};
use crate::config::AiConfig;

#[derive(Debug, Serialize)]
struct DeepSeekMessage {
    role: String,
    content: String,
}

#[derive(Debug, Serialize)]
struct DeepSeekRequest {
    model: String,
    messages: Vec<DeepSeekMessage>,
    temperature: f64,
    max_tokens: u32,
}

#[derive(Debug, Deserialize)]
struct DeepSeekUsage {
    total_tokens: Option<i64>,
}

#[derive(Debug, Deserialize)]
struct DeepSeekResponse {
    choices: Vec<DeepSeekChoice>,
    usage: Option<DeepSeekUsage>,
}

#[derive(Debug, Deserialize)]
struct DeepSeekChoice {
    message: DeepSeekMessageResponse,
}

#[derive(Debug, Deserialize)]
struct DeepSeekMessageResponse {
    content: String,
}

#[derive(Debug, Clone)]
pub enum HintLevel {
    ErrorLocation,
    CorrectionHint,
    OperationSuggestion,
}

impl HintLevel {
    pub fn from_str(s: &str) -> Self {
        match s {
            "error_explanation" => HintLevel::ErrorLocation,
            "hint" => HintLevel::CorrectionHint,
            _ => HintLevel::OperationSuggestion,
        }
    }

    pub fn system_prompt(&self) -> &'static str {
        match self {
            HintLevel::ErrorLocation => {
                "你是一名面向前端初学者的学习辅助教练。请根据题目要求、学习者提交的 HTML/CSS 代码和失败上下文，只解释当前最可能出错的位置与现象。

不要直接给出完整答案代码。

请使用简洁中文回答，包含以下三部分：
1) 当前错误最可能出现在哪一段结构或样式；
2) 它导致了什么可观察现象；
3) 学习者下一步应该先检查什么。

请以 JSON 格式返回，包含以下字段：
- hint_level: 1
- summary: 简短的问题摘要
- error_location: {section, selector, property} 错误位置
- observable_symptom: 可观察到的现象
- next_check: 下一步应该检查什么"
            }
            HintLevel::CorrectionHint => {
                "你是一名面向前端初学者的学习辅助教练。请在不直接给出完整代码答案的前提下，解释问题产生的原因，并给出修正方向。

请结合题目要求、提交代码和失败上下文，输出以下内容：
1) 失败最可能由哪一类原因导致；
2) 学习者应优先修改布局结构、选择器覆盖、断点条件还是属性值；
3) 给出 2 条不含完整答案的方向性建议。

请以 JSON 格式返回，包含以下字段：
- hint_level: 2
- summary: 问题摘要
- root_cause: {category, detail} 问题原因
- direction: {priority, reason} 修正方向
- suggestions: [建议1, 建议2] 方向性建议"
            }
            HintLevel::OperationSuggestion => {
                "你是一名面向前端初学者的学习辅助教练。学习者已经获得基础解释，但仍然没有修复问题。请输出可执行的下一步操作建议，帮助其继续尝试。

要求：
1) 仅给出步骤，不直接生成完整答案；
2) 每一步都应能在当前编辑器中立即尝试；
3) 最多给出 4 步；
4) 最后提醒学习者重新提交并观察哪个公开用例发生变化。

请以 JSON 格式返回，包含以下字段：
- hint_level: 3
- summary: 简短的行动摘要
- action_steps: [{step, action, expected}] 操作步骤列表
- final_reminder: 最后提醒"
            }
        }
    }
}

#[derive(Debug, Serialize)]
struct AiHelpInput {
    exercise_prompt: String,
    source_code: String,
    error_context: Option<serde_json::Value>,
    attempt_no: u32,
    hint_level: u32,
    previous_hints: Option<Vec<String>>,
}

pub struct AiService {
    client: reqwest::Client,
    config: AiConfig,
}

impl AiService {
    pub fn new(config: AiConfig) -> Self {
        Self {
            client: reqwest::Client::new(),
            config,
        }
    }

    pub async fn request_help(
        &self,
        exercise_prompt: &str,
        source_code: &str,
        error_context: Option<&serde_json::Value>,
        request_type: &str,
        attempt_no: u32,
        previous_hints: Option<Vec<String>>,
    ) -> Result<(String, serde_json::Value, String, Option<i32>), String> {
        let hint_level = HintLevel::from_str(request_type);
        
        if self.config.provider == "mock" {
            return Ok((
                self.config.mock_response.clone(),
                serde_json::json!({"message": self.config.mock_response}),
                "mock".to_string(),
                None,
            ));
        }

        let api_key = self.config.api_key.as_ref()
            .ok_or_else(|| "API key not configured".to_string())?;

        let input = AiHelpInput {
            exercise_prompt: exercise_prompt.to_string(),
            source_code: source_code.to_string(),
            error_context: error_context.cloned(),
            attempt_no,
            hint_level: match &hint_level {
                HintLevel::ErrorLocation => 1,
                HintLevel::CorrectionHint => 2,
                HintLevel::OperationSuggestion => 3,
            },
            previous_hints,
        };

        let request = DeepSeekRequest {
            model: self.config.model.clone(),
            messages: vec![
                DeepSeekMessage {
                    role: "system".to_string(),
                    content: hint_level.system_prompt().to_string(),
                },
                DeepSeekMessage {
                    role: "user".to_string(),
                    content: serde_json::to_string(&input).unwrap_or_default(),
                },
            ],
            temperature: self.config.temperature,
            max_tokens: self.config.max_tokens,
        };

        let response = self.client
            .post("https://api.deepseek.com/chat/completions")
            .header("Authorization", format!("Bearer {}", api_key))
            .header("Content-Type", "application/json")
            .json(&request)
            .send()
            .await
            .map_err(|e| format!("Failed to call DeepSeek API: {}", e))?;

        if !response.status().is_success() {
            let status = response.status();
            let body = response.text().await.unwrap_or_default();
            return Err(format!("DeepSeek API returned error {}: {}", status, body));
        }

        let response_body: DeepSeekResponse = response.json().await
            .map_err(|e| format!("Failed to parse DeepSeek response: {}", e))?;

        let content = response_body.choices.first()
            .ok_or_else(|| "No choices in response".to_string())?
            .message
            .content
            .clone();

        let token_usage = response_body.usage.as_ref().map(|u| u.total_tokens.unwrap_or(0) as i32);

        let response_json = serde_json::from_str(&content)
            .unwrap_or_else(|_| serde_json::json!({"raw_response": content}));

        Ok((content, response_json, self.config.model.clone(), token_usage))
    }
}
