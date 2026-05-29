# Services — 业务逻辑层开发指南

> 面向 AI Agent 的 Service 层规范。上级规范见 [../../AGENTS.md](../../AGENTS.md) 和 [../AGENTS.md](../AGENTS.md)。

---

## 1. 目录结构

```
backend/src/services/
├── judge_service.rs      # 判题引擎（mock / 测试用例匹配）
├── xp_service.rs         # XP 计算与发放
├── ai_service.rs         # DeepSeek API 封装
├── course_service.rs     # 课程列表/CRUD
├── progress_service.rs   # 学习进度 CRUD
└── account_service.rs    # 账户查询/创建
```

**Service 层无 HTTP 依赖**，不导入 `salvo`。

---

## 2. 两种 Service 风格

### 2.1 Struct 模式（有状态/无状态）

```rust
// 无状态
pub struct JudgeService;
impl JudgeService {
    pub async fn judge_submission(pool: &PgPool, submission_id: &str) 
        -> Result<JudgeResult, String> { ... }
}

// 有状态（持有 Client 和 Config）
pub struct AiService {
    client: reqwest::Client,
    config: AiConfig,
}
impl AiService {
    pub fn new(config: AiConfig) -> Self { ... }
    pub async fn ask(&self, prompt: &str) -> Result<String, AiError> { ... }
}
```

### 2.2 裸函数模式

```rust
pub async fn list_published_courses(pool: &PgPool, page: i64, page_size: i64) 
    -> Result<Vec<Course>, sqlx::Error> { ... }

pub async fn get_course_by_id(pool: &PgPool, id: Uuid) 
    -> Result<Option<Course>, sqlx::Error> { ... }
```

**选择原则**：
- 需要配置/状态 → Struct 模式
- 纯数据查询 → 裸函数模式
- 复杂业务逻辑 → Struct 模式

---

## 3. Service 调用链

### 3.1 判题流程

```
submission.rs (Handler)
    → JudgeService::judge_submission()
        → 获取 submission 记录
        → 获取 exercise 测试用例
        → 执行判题逻辑（mock / 真实 AI）
        → 更新 submission（score / status）
        → 返回 JudgeResult
    → XpService::reward_submission_xp() (异步，tokio::spawn)
```

### 3.2 AI 辅助流程

```
ai_help.rs (Handler)
    → AiService::ask()
        → 构建 prompt
        → 调用 DeepSeek API（或 mock）
        → 解析响应
        → 返回 AI 建议
```

### 3.3 XP 发放流程

```
challenge.rs / daily_challenge.rs (Handler)
    → tokio::spawn(XpService::reward_xxx_xp())
        → 计算 XP 值
        → 写入 XpLedger
        → 更新 LearnerProfile.total_xp
        → 检查徽章条件
```

**注意**：XP 奖励通过 `tokio::spawn` 异步后置，不阻塞 HTTP 响应。

---

## 4. 关键约定

### 4.1 参数传递

```rust
// ✅ 正确：传入 &PgPool
pub async fn some_service(pool: &PgPool, ...) -> Result<...> { ... }

// ❌ 错误：传入 &mut Depot（Service 层不应知道 HTTP）
```

### 4.2 错误处理

```rust
// ✅ 正确：返回具体错误类型
pub async fn some_service(...) -> Result<T, ServiceError> { ... }

// 或使用 thiserror 定义错误枚举
#[derive(thiserror::Error, Debug)]
pub enum ServiceError {
    #[error("Database error: {0}")]
    Database(#[from] sqlx::Error),
    #[error("AI service error: {0}")]
    Ai(String),
}
```

### 4.3 配置读取

```rust
// 从 AppConfig 读取（由 Handler 传入）
pub struct AiConfig {
    pub provider: String,  // "mock" / "deepseek"
    pub api_key: String,
    pub model: String,
}
```

---

## 5. 已知陷阱

| 问题 | 影响 | 解决方案 |
|------|------|---------|
| `account_service.rs` 中 `#[allow(dead_code)]` | 代码未使用 | 确认是否需要，或移除 |
| `judge_service.rs` 中 `eprintln!` | 日志不一致 | 替换为 `tracing::error!` |
| `ai_service.rs` 中 `unwrap_or_else` | 静默回盖非 JSON 响应 | 添加错误日志 |
| 异步 XP 奖励失败 | 静默失败 | 添加错误处理和重试 |

---

## 6. 添加新 Service 的步骤

1. 在 `src/services/{name}_service.rs` 中实现
2. 在 `src/services/mod.rs` 中声明模块
3. 在 Handler 中调用（通过 `depot.obtain::<PgPool>()` 获取 pool 传入）
4. 如需配置，从 `AppConfig` 中提取

---

## 7. Service 依赖关系

```
judge_service.rs
    ├── 依赖：models.rs（Submission, Exercise, TestCase）
    └── 被依赖：submission.rs（Handler）

xp_service.rs
    ├── 依赖：models.rs（XpLedger, LearnerProfile, Badge）
    └── 被依赖：challenge.rs, daily_challenge.rs, submission.rs

ai_service.rs
    ├── 依赖：config.rs（AiConfig）
    └── 被依赖：ai_help.rs, judge_service.rs

course_service.rs
    ├── 依赖：models.rs（Course, Chapter）
    └── 被依赖：course.rs, admin.rs

progress_service.rs
    ├── 依赖：models.rs（CourseProgress）
    └── 被依赖：progress.rs

account_service.rs
    ├── 依赖：models.rs（Account）
    └── 被依赖：auth.rs（部分函数）
```

---

## 8. Service 文件清单

```
backend/src/services/
├── judge_service.rs      # 判题引擎（mock / 测试用例匹配）
├── xp_service.rs         # XP 计算与发放
├── ai_service.rs         # DeepSeek API 封装
├── course_service.rs     # 课程列表/CRUD
├── progress_service.rs   # 学习进度 CRUD
└── account_service.rs    # 账户查询/创建
```

**Service 层无 HTTP 依赖**，不导入 `salvo`。

---

## 9. 已知非标准模式

| 问题 | 位置 | 影响 | 解决方案 |
|------|------|------|---------|
| `account_service.rs` 中 `#[allow(dead_code)]` | `services/account_service.rs` | 代码未使用 | 确认是否需要，或移除 |
| `judge_service.rs` 中 `eprintln!` | `services/judge_service.rs` | 日志不一致 | 替换为 `tracing::error!` |
| `ai_service.rs` 中 `unwrap_or_else` | `services/ai_service.rs` | 静默回盖非 JSON 响应 | 添加错误日志 |
| 异步 XP 奖励失败 | `services/xp_service.rs` | 静默失败 | 添加错误处理和重试 |
