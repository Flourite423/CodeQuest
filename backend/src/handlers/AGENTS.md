# Handlers — HTTP Handler 开发指南

> 面向 AI Agent 的 Handler 层规范。上级规范见 [../../AGENTS.md](../../AGENTS.md) 和 [../AGENTS.md](../AGENTS.md)。

---

## 1. 目录结构

```
backend/src/handlers/
├── mod.rs              # health_check + not_found + 模块声明
├── auth.rs             # 注册/登录/JWT/刷新/登出（~669行）
├── course.rs           # 课程列表/详情
├── chapter.rs          # 章节 CRUD
├── exercise.rs         # 练习 CRUD
├── submission.rs       # 代码提交 + 同步判题
├── challenge.rs        # 挑战 CRUD + 提交
├── daily_challenge.rs  # 每日挑战 + 自动复制
├── user.rs             # 个人资料/统计
├── social.rs           # 好友/动态/搜索
├── leaderboard.rs      # 排行榜
├── reward.rs           # XP/徽章
├── ai_help.rs          # AI 辅助
├── progress.rs         # 学习进度
└── admin.rs            # 管理后台全功能（~1585行，最大文件）
```

**按领域分文件**，每个文件包含该领域的全部 HTTP Handler 函数。

---

## 2. Handler 函数签名模式

Salvo 根据函数签名自动注入参数：

```rust
// 只需要数据库池
pub async fn list_courses(depot: &mut Depot) -> Result<Json<ApiResponse<...>>, StatusError>

// 需要路径参数
pub async fn get_course(req: &mut Request, depot: &mut Depot) -> Result<...>

// 需要请求体
pub async fn create_course(req: &mut Request, depot: &mut Depot) -> Result<...>

// 需要设置状态码
pub async fn delete_course(req: &mut Request, depot: &mut Depot, res: &mut Response) -> Result<StatusCode, StatusError>
```

**返回类型**：
- `Result<Json<ApiResponse<T>>, StatusError>` — 成功返回 JSON
- `Result<StatusCode, StatusError>` — 仅返回状态码（如 204 No Content）
- `Result<(StatusCode, Json<ApiResponse<T>>), StatusError>` — 状态码 + JSON（如 201 Created）

---

## 3. 标准 Handler 模板

```rust
use salvo::prelude::*;
use sqlx::PgPool;
use uuid::Uuid;
use crate::handlers::auth;
use crate::models::{ApiResponse, SomeModel};

#[handler]
pub async fn some_handler(req: &mut Request, depot: &mut Depot)
    -> Result<Json<ApiResponse<SomeModel>>, StatusError>
{
    // 1. 获取数据库池
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    // 2. 获取当前用户（如需鉴权）
    // let account_id = auth::get_current_account_id(depot)?;

    // 3. 解析路径参数
    let id_str = req.param::<String>("some_id")
        .ok_or_else(StatusError::bad_request)?;
    let id = Uuid::parse_str(&id_str)
        .map_err(|_| StatusError::bad_request().brief("Invalid ID"))?;

    // 4. 执行查询
    let result = sqlx::query_as::<_, SomeModel>(
        "SELECT ... FROM ... WHERE id = $1"
    )
    .bind(id)
    .fetch_one(pool)
    .await
    .map_err(|_| StatusError::not_found())?;

    // 5. 返回信封响应
    Ok(Json(ApiResponse::new(result)))
}
```

---

## 4. 关键约定

### 4.1 获取当前用户

```rust
// 获取用户 ID（Uuid）
let account_id = auth::get_current_account_id(depot)?;

// 获取用户角色（"admin" / "learner"）
let role = auth::get_current_role(depot)?;
```

### 4.2 路径参数解析

```rust
// ✅ 正确：先解析为 Uuid 再绑定
let id = Uuid::parse_str(&id_str)
    .map_err(|_| StatusError::bad_request().brief("Invalid ID"))?;

// ❌ 错误：直接绑定 String 到 uuid 列
// .bind(id_str)  // 会导致 operator does not exist: uuid = text
```

### 4.3 枚举类型转换

```rust
// ✅ 正确：显式类型转换
WHERE status::text = $2

// ❌ 错误：直接比较
// WHERE status = $2  // 当 $2 为 text 时会失败
```

### 4.4 错误处理

```rust
// ✅ 正确：map_err + StatusError
let result = sqlx::query(...)
    .fetch_one(pool)
    .await
    .map_err(|_| StatusError::not_found())?;

// ❌ 错误：unwrap
// let result = sqlx::query(...).fetch_one(pool).await.unwrap();
```

### 4.5 分页参数

```rust
let page = req.query::<i64>("page").unwrap_or(1).max(1);
let page_size = req.query::<i64>("page_size").unwrap_or(20).clamp(1, 100);
let offset = (page - 1) * page_size;
```

---

## 5. 已知陷阱

| 问题 | 影响 | 解决方案 |
|------|------|---------|
| `String` 直接 bind 到 UUID 列 | PostgreSQL 隐式转换效率低 | 始终 `Uuid::parse_str` + `bind(id)` |
| `eprintln!` 代替 `tracing` | 日志不一致 | 使用 `tracing::error!` |
| `unwrap()` 在 Handler 中 |  panic | 使用 `map_err` + `StatusError` |
| `RETURNING *` | 自定义类型映射问题 | 显式列名 + `::text` 转换 |
| 错误信息丢弃 | `map_err(|_| ...)` | 至少记录错误详情 |

---

## 6. 特殊 Handler

### 6.1 同步判题（submission.rs）

```
前端提交代码
    → 创建 pending submission 记录
    → 调用 JudgeService::judge_submission(pool, &submission_id)
    → 等待判题完成
    → 更新数据库（score / passed_case_count / judge_status）
    → 返回最终 Submission
```

**注意**：同步判题会阻塞 HTTP 线程。如需异步，前端需轮询 `GET /learner/submissions/{id}`。

### 6.2 自动复制每日挑战（daily_challenge.rs）

如果当天无生效挑战，系统自动从最近生效挑战复制一个。此行为**静默生成记录**。

### 6.3 管理后台（admin.rs）

- 最大 Handler 文件（~1585 行）
- 大量使用 `serde_json::Value` 作为请求体（灵活性高，编译时验证低）
- 包含 25+ 个管理端点

---

## 7. 添加新 Handler 的步骤

1. 在 `contracts/openapi/openapi.yaml` 中定义端点
2. 在 `src/models.rs` 中添加/更新 Model
3. 在 `src/handlers/{domain}.rs` 中实现 Handler
4. 在 `src/routes.rs` 中注册路由
5. 返回格式：始终 `ApiResponse<T>` 或 `ApiError`
