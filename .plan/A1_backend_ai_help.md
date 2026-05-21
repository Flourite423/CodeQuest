# 任务 A1: Backend AI Help Handler 完善

## 背景
当前 `backend/src/handlers/ai_help.rs` 中 `exercise_prompt` 是硬编码的 `"Exercise prompt placeholder"`，`request_type` 映射不完整，且 `token_usage`/`latency_ms` 都是硬编码 0。

`backend/src/services/ai_service.rs` 已经实现了 DeepSeek API 调用和三级提示策略，但 Handler 没有正确使用它。

## 目标
完善 AI Help Handler，使其能根据真实练习数据生成提示，正确映射三级请求类型，并记录真实的 token 使用量和延迟。

## 修改文件

### 1. `backend/src/handlers/ai_help.rs`

**需要修改的内容：**

#### a) 获取真实练习数据
创建提交前，根据 `exercise_id` 从数据库查询 `exercises` 表，获取 `title` + `description` + `starter_code` 拼接成 `exercise_prompt`。

SQL 查询示例：
```rust
let exercise = sqlx::query_as::<_, (String, String, Option<String>)>(
    "SELECT title, description, starter_code FROM exercises WHERE id = $1"
)
.bind(exercise_id)
.fetch_optional(pool)
.await
.map_err(|_| StatusError::internal_server_error())?;

let exercise_prompt = match exercise {
    Some((title, desc, starter)) => {
        format!("题目：{}\n描述：{}\n初始代码：{}", title, desc, starter.unwrap_or_default())
    }
    None => "Exercise prompt unavailable".to_string(),
};
```

#### b) 完善 request_type 三级映射
当前映射：
```rust
let request_type = match body.request_type.as_str() {
    "error_explanation" => crate::models::AiRequestType::ErrorExplanation,
    "hint" => crate::models::AiRequestType::Hint,
    _ => crate::models::AiRequestType::Hint,
};
```

应改为映射到论文要求的三级：
```rust
let request_type = match body.request_type.as_str() {
    "error_location" | "error_explanation" => crate::models::AiRequestType::ErrorLocation,
    "correction_hint" | "hint" => crate::models::AiRequestType::CorrectionHint,
    "operation_suggestion" => crate::models::AiRequestType::OperationSuggestion,
    _ => crate::models::AiRequestType::Hint,
};
```

> 注意：如果 `models.rs` 中没有 `AiRequestType::ErrorLocation`/`CorrectionHint`/`OperationSuggestion` 枚举值，需要同步修改 `models.rs` 添加这些变体。

#### c) 记录真实 token_usage 和 latency_ms
在调用 `ai_service.request_help()` 前后添加计时：
```rust
let start = std::time::Instant::now();
let ai_result = ai_service.request_help(...).await;
let latency_ms = start.elapsed().as_millis() as i32;

let (response_text, response_json, provider, token_usage) = match ai_result {
    Ok((text, json, prov)) => {
        // 从 response_json 中解析 token usage
        let tokens = response_json.get("usage").and_then(|u| u.get("total_tokens")).and_then(|t| t.as_i64()).unwrap_or(0) as i32;
        (text, json, prov, tokens)
    }
    Err(e) => {
        eprintln!("AI service error: {}", e);
        (cfg.ai.mock_response.clone(), serde_json::json!({"message": cfg.ai.mock_response}), "fallback".to_string(), 0)
    }
};
```

然后将 `token_usage` 和 `latency_ms` 绑定到 INSERT 语句中（替换当前的 `0, 0`）。

### 2. `backend/src/models.rs`（如需）

检查 `AiRequestType` 枚举定义，确保有以下变体：
```rust
pub enum AiRequestType {
    ErrorLocation,
    CorrectionHint,
    OperationSuggestion,
    ErrorExplanation,  // 保留向后兼容
    Hint,              // 保留向后兼容
}
```

如果缺少，需要添加。同时确保 `sqlx::Type` derive 和数据库枚举类型 `ai_request_type` 对齐。

### 3. `backend/src/services/ai_service.rs`（如需微调）

检查 `request_help` 的返回类型是否包含 token usage 信息。目前返回的是 `(String, serde_json::Value, String)`（文本、JSON、provider）。

由于 DeepSeek API 的 usage 信息在响应的顶层（不在 content 中），而当前 `DeepSeekResponse` 结构体可能没有 `usage` 字段，需要：

- 在 `DeepSeekResponse` 中添加 `usage` 字段
- 在 `request_help` 中解析并返回 token usage

或者更简单的方案：在 Handler 中直接解析返回的 JSON 字符串来获取 usage。

建议修改 `request_help` 返回类型为 `(String, serde_json::Value, String, Option<i32>)`（最后一个为 token_usage）。

### 4. `backend/config/default.toml`（如需）

确保 AI 配置项完整：
```toml
[ai]
provider = "mock"  # 开发用 mock，生产改为 "deepseek"
api_key = ""
model = "deepseek-chat"
temperature = 0.3
max_tokens = 500
mock_response = "这是一条模拟的 AI 帮助响应。"
```

## 测试验证
- [ ] 运行 `cd backend && cargo test tests::ai_help_test` 或相关测试
- [ ] Mock 模式下正常返回模拟响应
- [ ] 数据库中的 `ai_help_requests` 记录包含正确的 `exercise_prompt`（非占位符）
- [ ] `token_usage` 和 `latency_ms` 字段有真实值（mock 模式下可为 0）

## 注意
- 保持错误处理风格与项目一致（使用 `map_err` + `StatusError`）
- 不要改变现有 API 响应格式（仍包裹 `ApiResponse<AiHelpRequest>`）
- 如果修改了 `models.rs` 中的枚举，需要确保数据库枚举类型兼容
