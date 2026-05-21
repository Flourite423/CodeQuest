# 任务 A2: Backend 代码判题系统

## 背景
当前提交系统 (`handlers/submission.rs`) 只保存提交记录，`judge_status` 永远为 `pending`，没有实际的代码执行和判题逻辑。

## 目标
实现最简版本的代码判题系统，支持 HTML/CSS 练习的测试用例匹配。

## 修改文件

### 1. 新建 `backend/src/services/judge_service.rs`

```rust
use serde::{Deserialize, Serialize};
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

pub struct JudgeService;

impl JudgeService {
    /// 对一次提交进行判题
    pub async fn judge_submission(
        pool: &PgPool,
        submission_id: &str,
    ) -> Result<JudgeResult, String> {
        let start = std::time::Instant::now();

        // 1. 获取提交详情和练习测试用例
        let record = sqlx::query_as::<_, (String, String, String)>(
            "SELECT s.source_code, e.test_cases, e.exercise_type::text 
             FROM submissions s 
             JOIN exercises e ON s.exercise_id = e.id 
             WHERE s.id = $1"
        )
        .bind(submission_id)
        .fetch_optional(pool)
        .await
        .map_err(|e| format!("DB error: {}", e))?;

        let (source_code, test_cases_json, exercise_type) = match record {
            Some(r) => r,
            None => return Err("Submission not found".to_string()),
        };

        // 2. 解析测试用例
        let test_cases: Vec<TestCase> = serde_json::from_str(&test_cases_json)
            .unwrap_or_default();

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

        // 3. 根据题型执行判题
        let mut passed = 0;
        let mut errors = Vec::new();

        for case in &test_cases {
            match exercise_type.as_str() {
                "html" | "css" => {
                    // HTML/CSS 判题：字符串匹配/包含检查
                    if Self::check_html_css(&source_code, case) {
                        passed += 1;
                    } else {
                        errors.push(format!("用例 '{}' 未通过", case.description));
                    }
                }
                "javascript" | "js" => {
                    // JS 判题：简化版，未来可接入沙箱
                    passed += 1; // 暂时全部通过
                }
                _ => {
                    passed += 1;
                }
            }
        }

        let total = test_cases.len() as i32;
        let passed_count = passed;
        let score = if total > 0 { (passed_count * 100) / total } else { 0 };
        let status = if passed_count == total { JudgeStatus::Passed } else { JudgeStatus::Failed };
        let error_summary = if errors.is_empty() { None } else { Some(errors.join("\n")) };
        let runtime_ms = start.elapsed().as_millis() as i32;

        Ok(JudgeResult {
            status,
            score,
            passed_case_count: passed_count,
            total_case_count: total,
            error_summary,
            runtime_ms,
        })
    }

    /// HTML/CSS 测试用例检查
    fn check_html_css(source: &str, case: &TestCase) -> bool {
        // 检查是否包含特定标签/属性/选择器
        if let Some(ref contains) = case.should_contain {
            for item in contains {
                if !source.contains(item) {
                    return false;
                }
            }
        }
        // 检查是否不包含特定内容
        if let Some(ref not_contains) = case.should_not_contain {
            for item in not_contains {
                if source.contains(item) {
                    return false;
                }
            }
        }
        true
    }
}

#[derive(Debug, Deserialize)]
struct TestCase {
    description: String,
    should_contain: Option<Vec<String>>,
    should_not_contain: Option<Vec<String>>,
}
```

### 2. 修改 `backend/src/services/mod.rs`

添加 `pub mod judge_service;`

### 3. 修改 `backend/src/handlers/submission.rs`

在 `create_submission` 处理提交创建后，异步触发判题：

```rust
use crate::services::judge_service::JudgeService;

// 在 create_submission 函数末尾，插入成功后触发判题
let submission_id_str = submission.id.to_string();
let pool_clone = pool.clone();

tokio::spawn(async move {
    match JudgeService::judge_submission(&pool_clone, &submission_id_str).await {
        Ok(result) => {
            // 更新提交状态
            let _ = sqlx::query(
                "UPDATE submissions 
                 SET judge_status = $2, score = $3, 
                     passed_case_count = $4, total_case_count = $5, 
                     error_summary = $6, runtime_ms = $7, completed_at = NOW()
                 WHERE id = $1"
            )
            .bind(&submission_id_str)
            .bind(result.status.as_str())
            .bind(result.score)
            .bind(result.passed_case_count)
            .bind(result.total_case_count)
            .bind(result.error_summary)
            .bind(result.runtime_ms)
            .execute(&pool_clone)
            .await;
        }
        Err(e) => {
            eprintln!("Judge error: {}", e);
            let _ = sqlx::query(
                "UPDATE submissions SET judge_status = 'error', error_summary = $2 WHERE id = $1"
            )
            .bind(&submission_id_str)
            .bind(Some(e))
            .execute(&pool_clone)
            .await;
        }
    }
});
```

### 4. `backend/src/models.rs`（如需）

确保 `Submission` 模型中的 `judge_status` 字段类型与数据库兼容。当前查询中使用 `judge_status::text AS judge_status`，返回字符串类型即可。

## 测试验证
- [ ] 创建提交后，数据库中 `judge_status` 最终变为 `passed` 或 `failed`
- [ ] `score`/`passed_case_count`/`total_case_count` 有正确值
- [ ] 测试用例为空时返回 `passed` + score=100
- [ ] 运行 `cd backend && cargo test tests::submission_test`

## 注意
- 判题使用 `tokio::spawn` 异步执行，不阻塞 HTTP 响应
- 当前为最简实现（字符串匹配），后续可升级为沙箱执行
- 错误处理需记录到 tracing log，不要 panic
