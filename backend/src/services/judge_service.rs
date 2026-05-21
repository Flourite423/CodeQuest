use serde_json::Value;
use sqlx::PgPool;

#[derive(Debug, Clone)]
pub struct JudgeResult {
    pub status: JudgeStatus,
    pub score: i32,
    pub passed_case_count: i32,
    pub total_case_count: i32,
    pub error_summary: Option<String>,
    pub runtime_ms: i32,
}

#[derive(Debug, Clone)]
pub enum JudgeStatus {
    Passed,
    Failed,
    #[allow(dead_code)]
    Error,
}

impl JudgeStatus {
    pub fn as_str(&self) -> &'static str {
        match self {
            JudgeStatus::Passed => "passed",
            JudgeStatus::Failed => "failed",
            JudgeStatus::Error => "error",
        }
    }
}

/// A single row from the exercise_test_cases table
#[derive(Debug, sqlx::FromRow)]
struct TestCaseRow {
    case_name: String,
    case_type: String,
    expected_payload_json: Value,
}

pub struct JudgeService;

impl JudgeService {
    /// 对一次提交进行判题
    pub async fn judge_submission(
        pool: &PgPool,
        submission_id: &str,
    ) -> Result<JudgeResult, String> {
        let start = std::time::Instant::now();

        // 1. 获取提交详情
        let submission = sqlx::query_as::<_, (String, String)>(
            "SELECT source_code, exercise_id::text FROM submissions WHERE id = $1",
        )
        .bind(submission_id)
        .fetch_optional(pool)
        .await
        .map_err(|e| format!("DB error fetching submission: {}", e))?;

        let (source_code, exercise_id) = match submission {
            Some(r) => r,
            None => return Err("Submission not found".to_string()),
        };

        // 2. 获取练习信息
        let exercise = sqlx::query_as::<_, (String,)>(
            "SELECT exercise_type::text FROM exercises WHERE id = $1",
        )
        .bind(&exercise_id)
        .fetch_optional(pool)
        .await
        .map_err(|e| format!("DB error fetching exercise: {}", e))?;

        let exercise_type = match exercise {
            Some((t,)) => t,
            None => return Err("Exercise not found".to_string()),
        };

        // 3. 获取测试用例
        let test_cases = sqlx::query_as::<_, TestCaseRow>(
            "SELECT case_name, case_type, expected_payload_json \
             FROM exercise_test_cases \
             WHERE exercise_id = $1 \
             ORDER BY order_index ASC",
        )
        .bind(&exercise_id)
        .fetch_all(pool)
        .await
        .map_err(|e| format!("DB error fetching test cases: {}", e))?;

        if test_cases.is_empty() {
            return Ok(JudgeResult {
                status: JudgeStatus::Passed,
                score: 100,
                passed_case_count: 0,
                total_case_count: 0,
                error_summary: None,
                runtime_ms: 0,
            });
        }

        // 4. 根据题型执行判题
        let mut passed = 0i32;
        let mut errors: Vec<String> = Vec::new();

        for case in &test_cases {
            let ok = match exercise_type.as_str() {
                "html" | "css" => Self::check_case(&source_code, case),
                "javascript" | "js" => Self::check_case(&source_code, case),
                _ => Self::check_case(&source_code, case),
            };
            if ok {
                passed += 1;
            } else {
                errors.push(format!("用例 '{}' 未通过", case.case_name));
            }
        }

        let total = test_cases.len() as i32;
        let score = if total > 0 {
            (passed * 100) / total
        } else {
            0
        };
        let status = if passed == total {
            JudgeStatus::Passed
        } else {
            JudgeStatus::Failed
        };
        let error_summary = if errors.is_empty() {
            None
        } else {
            Some(errors.join("\n"))
        };
        let runtime_ms = start.elapsed().as_millis() as i32;

        Ok(JudgeResult {
            status,
            score,
            passed_case_count: passed,
            total_case_count: total,
            error_summary,
            runtime_ms,
        })
    }

    /// 统一分发：根据 case_type 选择检查逻辑
    fn check_case(source: &str, case: &TestCaseRow) -> bool {
        match case.case_type.as_str() {
            "text_match" => Self::check_text_match(source, &case.expected_payload_json),
            "dom_snapshot" => Self::check_dom_snapshot(source, &case.expected_payload_json),
            "css_assert" => Self::check_css_assert(source, &case.expected_payload_json),
            _ => true, // 未知类型默认通过
        }
    }

    /// text_match: 基于文本匹配
    /// expected_payload_json 示例:
    ///   {"pattern": "<!DOCTYPE html>", "match_type": "contains"}
    ///   {"pattern": "regex.*", "match_type": "regex_contains"}
    fn check_text_match(source: &str, expected: &Value) -> bool {
        let pattern = match expected.get("pattern").and_then(|v| v.as_str()) {
            Some(p) => p,
            None => return true,
        };
        let match_type = expected
            .get("match_type")
            .and_then(|v| v.as_str())
            .unwrap_or("contains");

        match match_type {
            "contains" => source.contains(pattern),
            "not_contains" => !source.contains(pattern),
            "regex_contains" => {
                // 简化版 regex: 按 ".*" 分割，检查各片段依次出现
                Self::simple_regex_match(source, pattern)
            }
            "exact" => source.trim() == pattern,
            "starts_with" => source.trim_start().starts_with(pattern),
            "ends_with" => source.trim_end().ends_with(pattern),
            _ => source.contains(pattern),
        }
    }

    /// dom_snapshot: 基于源码的简化 DOM 检查
    /// expected_payload_json 示例:
    ///   {"selector": "title", "textContent": "我的第一个网页"}
    ///   {"exists": true, "selector": "header nav"}
    ///   {"count": 2, "selector": "h2"}
    ///   {"selector": "html", "attribute": "lang", "equals": "zh-CN"}
    fn check_dom_snapshot(source: &str, expected: &Value) -> bool {
        // textContent 检查: selector 存在且内容匹配
        if let (Some(selector), Some(text_content)) = (
            expected.get("selector").and_then(|v| v.as_str()),
            expected.get("textContent").and_then(|v| v.as_str()),
        ) {
            // 检查标签是否包含指定文本内容
            return Self::check_element_text_content(source, selector, text_content);
        }

        // attribute 检查: selector 的属性值匹配
        if let (Some(selector), Some(attribute), Some(equals)) = (
            expected.get("selector").and_then(|v| v.as_str()),
            expected.get("attribute").and_then(|v| v.as_str()),
            expected.get("equals").and_then(|v| v.as_str()),
        ) {
            return Self::check_attribute(source, selector, attribute, equals);
        }

        // exists 检查: selector 存在
        if let (Some(exists), Some(selector)) = (
            expected.get("exists").and_then(|v| v.as_bool()),
            expected.get("selector").and_then(|v| v.as_str()),
        ) {
            let has = Self::check_selector_exists(source, selector);
            return if exists { has } else { !has };
        }

        // count 检查: selector 出现次数
        if let (Some(count), Some(selector)) = (
            expected.get("count").and_then(|v| v.as_i64()),
            expected.get("selector").and_then(|v| v.as_str()),
        ) {
            let actual = Self::count_selector(source, selector);
            return actual >= count as usize;
        }

        true
    }

    /// css_assert: 基于源码的简化 CSS 属性检查
    /// expected_payload_json 示例:
    ///   {"selector": "nav a", "property": "color", "equals": "#333"}
    fn check_css_assert(source: &str, expected: &Value) -> bool {
        let (selector, property, equals) = match (
            expected.get("selector").and_then(|v| v.as_str()),
            expected.get("property").and_then(|v| v.as_str()),
            expected.get("equals").and_then(|v| v.as_str()),
        ) {
            (Some(s), Some(p), Some(e)) => (s, p, e),
            _ => return true,
        };

        // 简化检查：源码中是否包含 selector 和 property: value 的组合
        Self::check_css_property(source, selector, property, equals)
    }

    // ── 辅助方法 ──────────────────────────────────────────

    /// 检查元素文本内容（简化版：查找 <tag>...</tag> 并匹配文本）
    fn check_element_text_content(source: &str, tag: &str, expected_text: &str) -> bool {
        // 查找 <tag> 或 <tag ...> 开始标签
        let open_patterns: Vec<String> = vec![
            format!("<{}>", tag),
            format!("<{} ", tag),
        ];
        let close_tag = format!("</{}>", tag);

        for open_pattern in &open_patterns {
            if let Some(start_idx) = source.find(open_pattern.as_str()) {
                if let Some(end_idx) = source[start_idx..].find(&close_tag) {
                    let content = &source[start_idx + open_pattern.len()..start_idx + end_idx];
                    let trimmed = content.trim();
                    // 支持嵌套标签，取最终文本内容
                    let text = Self::extract_inner_text(trimmed);
                    if text.contains(expected_text) {
                        return true;
                    }
                }
            }
        }
        false
    }

    /// 提取纯文本内容（去除标签）
    fn extract_inner_text(html_fragment: &str) -> String {
        let mut result = String::new();
        let mut in_tag = false;
        for c in html_fragment.chars() {
            match c {
                '<' => in_tag = true,
                '>' => in_tag = false,
                _ if !in_tag => result.push(c),
                _ => {}
            }
        }
        result
    }

    /// 检查元素属性值
    fn check_attribute(source: &str, selector: &str, attribute: &str, expected_value: &str) -> bool {
        // 简化：查找 <selector ... attribute="value" ...>
        let attr_pattern = format!("{}=\"", attribute);
        // 先定位到 selector 标签
        let tag_patterns: Vec<String> = vec![
            format!("<{} ", selector),
            format!("<{}", selector),
        ];
        for pattern in &tag_patterns {
            if let Some(tag_start) = source.find(pattern.as_str()) {
                let tag_end = source[tag_start..].find('>').unwrap_or(source.len() - tag_start);
                let tag_content = &source[tag_start..tag_start + tag_end];
                // 查找 attribute="value"
                if let Some(attr_start) = tag_content.find(&attr_pattern) {
                    let value_start = attr_start + attr_pattern.len();
                    if let Some(value_end) = tag_content[value_start..].find('"') {
                        let actual_value = &tag_content[value_start..value_start + value_end];
                        return actual_value == expected_value;
                    }
                }
            }
        }
        false
    }

    /// 检查 selector 是否存在
    fn check_selector_exists(source: &str, selector: &str) -> bool {
        // 处理 "header nav" 这类组合选择器
        let parts: Vec<&str> = selector.split_whitespace().collect();
        match parts.len() {
            1 => {
                let tag = parts[0];
                source.contains(&format!("<{}", tag))
            }
            2 => {
                // 简化：外层标签存在，内层标签在其中
                let outer = parts[0];
                let inner = parts[1];
                if let Some(outer_start) = source.find(&format!("<{}", outer)) {
                    if let Some(outer_end) = source[outer_start..].find(&format!("</{}>", outer)) {
                        let segment = &source[outer_start..outer_start + outer_end];
                        return segment.contains(&format!("<{}", inner));
                    }
                }
                false
            }
            _ => source.contains(&format!("<{}", parts[0])),
        }
    }

    /// 统计 selector 出现次数
    fn count_selector(source: &str, selector: &str) -> usize {
        let pattern = format!("<{}", selector);
        source.matches(&pattern).count()
    }

    /// 检查 CSS 属性（简化版）
    fn check_css_property(source: &str, selector: &str, property: &str, expected_value: &str) -> bool {
        // 检查源码中是否包含 selector 相关的 CSS 规则
        // 简化策略：检查是否包含 property: value 或 property:value
        let prop_colon_val = format!("{}:{}", property, expected_value);
        let prop_space_val = format!("{}: {}", property, expected_value);

        // 首先检查是否有与 selector 相关的 CSS 块
        if source.contains(&prop_colon_val) || source.contains(&prop_space_val) {
            return true;
        }

        // 也检查选择器嵌套关系（如 .navbar { display: flex }）
        if source.contains(selector) && (source.contains(&prop_colon_val) || source.contains(&prop_space_val)) {
            return true;
        }

        false
    }

    /// 简化版正则匹配（按 ".*" 分割，检查各片段依次出现在源码中）
    fn simple_regex_match(source: &str, pattern: &str) -> bool {
        // 把 .* 当作通配符分割
        let parts: Vec<&str> = pattern.split(".*").collect();
        if parts.len() <= 1 {
            return source.contains(pattern);
        }

        let mut search_from = 0;
        for part in &parts {
            if part.is_empty() {
                continue;
            }
            match source[search_from..].find(part) {
                Some(pos) => {
                    search_from = search_from + pos + part.len();
                }
                None => return false,
            }
        }
        true
    }
}
