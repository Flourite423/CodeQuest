# Backend — Rust/Salvo 开发指南

> 面向 AI Agent 的后端开发规范。根目录规范见 [../AGENTS.md](../AGENTS.md)。

---

## 1. 技术栈

| 组件 | 库 |
|------|-----|
| Web 框架 | Salvo |
| ORM/查询 | SQLx（compile-time checked SQL） |
| 数据库 | PostgreSQL 15+ |
| 认证 | JWT（jsonwebtoken）+ bcrypt |
| 序列化 | serde + serde_json |
| 配置 | figment（TOML + 环境变量） |
| 日志 | tracing + tracing-subscriber |
| 测试 | cargo test + sqlx test |

---

## 2. 目录结构

```
backend/
├── src/
│   ├── main.rs              # 入口：tracing → config → pool → router → serve
│   ├── routes.rs            # 路由总装（所有 Handler 在此挂载）
│   ├── handlers/            # HTTP Handler（按领域分文件）
│   │   ├── auth.rs          # 注册/登录/JWT/刷新/登出
│   │   ├── course.rs        # 课程列表/详情
│   │   ├── chapter.rs       # 章节内容/完成标记
│   │   ├── exercise.rs      # 练习列表/详情
│   │   ├── submission.rs    # 代码提交 + 同步判题
│   │   ├── challenge.rs     # 挑战列表/提交
│   │   ├── daily_challenge.rs
│   │   ├── user.rs          # 个人资料/统计/好友
│   │   ├── social.rs        # 好友/动态
│   │   ├── leaderboard.rs   # 排行榜
│   │   ├── ai_help.rs       # AI 辅助请求
│   │   ├── reward.rs        # 奖励/徽章/XP
│   │   ├── progress.rs      # 学习进度
│   │   └── admin.rs         # 管理后台 API
│   ├── models.rs            # 全部领域类型 + ApiResponse/ApiError
│   ├── services/            # 业务逻辑层（无 HTTP）
│   │   ├── judge_service.rs     # 代码判题（mock / real AI）
│   │   ├── xp_service.rs        # XP 计算与发放
│   │   ├── ai_service.rs        # AI API 封装
│   │   ├── course_service.rs
│   │   ├── progress_service.rs
│   │   └── account_service.rs
│   ├── middleware/          # CORS、请求日志、JWT 认证
│   │   ├── cors.rs
│   │   ├── logging.rs
│   │   └── mod.rs
│   └── config.rs            # AppConfig，figment 读取
├── migrations/              # SQLx 迁移（按顺序执行）
│   ├── 001_initial_schema.sql
│   ├── 002_increase_refresh_token_length.sql
│   ├── 003_add_performance_indexes.sql
│   ├── 004_feedback_moderation.sql
│   ├── 005_add_challenges_published_at.sql
│   ├── 006_comprehensive_seed_data.sql
│   ├── 007_extend_ai_request_type.sql
│   └── 008_fix_chapter_content_newlines.sql
├── config/
│   └── default.toml         # 默认配置（git 追踪）
│   # local.toml             # 本地覆盖（gitignored）
├── tests/                   # 集成测试
├── Cargo.toml
└── seed_data.sql            # 初始种子数据
```

---

## 3. 添加新 API 端点

**必须遵循 Contract-first**：

1. 更新 `contracts/openapi/openapi.yaml`
2. 添加/更新 Model：`src/models.rs`
3. 实现 Handler：`src/handlers/{domain}.rs`
4. 注册路由：`src/routes.rs`
5. 返回格式：始终 `ApiResponse<T>` 或 `ApiError`

---

## 4. Handler 模板

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
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;

    // 如需当前登录用户 ID
    // let account_id = auth::get_current_account_id(depot)?;

    let id_str = req.param::<String>("some_id")
        .ok_or_else(StatusError::bad_request)?;
    let id = Uuid::parse_str(&id_str)
        .map_err(|_| StatusError::bad_request().brief("Invalid ID"))?;

    let result = sqlx::query_as::<_, SomeModel>(
        "SELECT ... FROM ... WHERE id = $1"
    )
    .bind(id)
    .fetch_one(pool)
    .await
    .map_err(|_| StatusError::not_found())?;

    Ok(Json(ApiResponse::new(result)))
}
```

---

## 5. 数据库规范

### 5.1 Pool 注入

```rust
// ✅ 正确：注入 Pool
let pool = depot.obtain::<PgPool>()
    .map_err(|_| StatusError::internal_server_error())?;

// ❌ 错误：注入单个连接
```

### 5.2 UUID 绑定

```rust
// ✅ 正确：先解析为 Uuid 再绑定
let id = Uuid::parse_str(&id_str)
    .map_err(|_| StatusError::bad_request().brief("Invalid ID"))?;
.bind(id)

// ❌ 错误：直接绑定 String 到 uuid 列
// .bind(id_str)  // 会导致 operator does not exist: uuid = text
```

### 5.3 枚举类型转换

PostgreSQL 自定义枚举（如 `judge_status`、`course_status`）与 text 参数比较时：

```rust
// ✅ 正确：显式类型转换
WHERE status::text = $2

// ❌ 错误：直接比较
// WHERE status = $2  // 当 $2 为 text 时会失败
```

### 5.4 错误处理

```rust
// ✅ 正确：map_err + StatusError
let result = sqlx::query(...)
    .fetch_one(pool)
    .await
    .map_err(|_| StatusError::not_found())?;

// ❌ 错误：unwrap
// let result = sqlx::query(...).fetch_one(pool).await.unwrap();
```

---

## 6. 判题系统

### 6.1 同步判题流程

`submission.rs` 的 `create_submission` 采用**同步判题**：

```
前端提交代码
    → 创建 pending submission 记录
    → 调用 JudgeService::judge_submission(pool, &submission_id)
    → 等待判题完成
    → 更新数据库（score / passed_case_count / judge_status）
    → 返回最终 Submission
```

### 6.2 JudgeService

- 支持 `mock` 模式（配置 `APP__AI__PROVIDER=mock`）
- 支持真实 AI 判题（配置 `APP__AI__PROVIDER=deepseek` + API key）
- 判题通过后自动调用 `XpService::reward_submission_xp` 发放 XP

### 6.3 如需恢复异步判题

前端需要轮询获取结果：

```
POST /learner/submissions    → 返回 pending submission（含 id）
GET  /learner/submissions/{id} → 轮询获取最终 score / judge_status
```

---

## 7. 配置系统

使用 figment 读取配置，优先级：`local.toml` > 环境变量 > `default.toml`。

**环境变量前缀**：`APP__`，多级用双下划线：

```bash
APP__SERVER_ADDR=127.0.0.1:3001
APP__DATABASE_URL=postgres://postgres:postgres@localhost/learning_app
APP__AUTO_RUN_MIGRATIONS=false
APP__SEED_DEV_ACCOUNTS=false
APP__AI__PROVIDER=mock
APP__AI__API_KEY=sk-xxx
APP__AI__MODEL=deepseek-chat
```

---

## 8. 关键测试数据

| 实体 | ID | 说明 |
|------|-----|------|
| Course | `00000000-0000-0000-0000-000000000101` | HTML基础入门（4章节） |
| Chapter | `00000000-0000-0000-0000-000000000201` | 认识HTML |
| Exercise | `00000000-0000-0000-0000-000000000301` | 创建基本HTML页面（coding类型） |

---

## 9. 常用端点速查

```
GET    /api/v1/health                           健康检查

POST   /api/v1/auth/register                    注册
POST   /api/v1/auth/learner/login               学习者登录
POST   /api/v1/auth/admin/login                 管理员登录
POST   /api/v1/auth/refresh                     刷新 Token
POST   /api/v1/auth/logout                      登出

GET    /api/v1/learner/courses                  课程列表
GET    /api/v1/learner/courses/{id}             课程详情（含章节）
GET    /api/v1/learner/courses/{cid}/chapters/{chid}           章节详情
GET    /api/v1/learner/courses/{cid}/chapters/{chid}/exercises 章节练习列表
GET    /api/v1/learner/exercises/{id}           练习详情

POST   /api/v1/learner/submissions              提交代码（同步判题）
GET    /api/v1/learner/submissions/{id}         查询提交结果

POST   /api/v1/learner/ai/help                  AI 辅助

GET    /api/v1/learner/challenges               挑战列表
POST   /api/v1/learner/challenges/{id}/attempts 挑战提交

GET    /api/v1/learner/daily-challenges/today    今日挑战
POST   /api/v1/learner/daily-challenges/{id}/submit 每日挑战提交

GET    /api/v1/learner/profile                  个人资料
GET    /api/v1/learner/stats/personal           个人统计
GET    /api/v1/learner/leaderboards             排行榜
GET    /api/v1/learner/rewards                  奖励/徽章
GET    /api/v1/learner/activities               学习动态
GET    /api/v1/learner/friends                  好友列表

GET    /api/v1/admin/stats/dashboard            管理后台统计
```

---

## 10. 迁移管理

```bash
cd backend

# 创建新迁移
sqlx migrate add <description>

# 执行迁移
sqlx migrate run

# 回滚
sqlx migrate revert
```

迁移文件按数字前缀顺序执行，**不要修改已执行的迁移文件**。

---

## 11. 入口点与初始化顺序

### 11.1 main.rs 初始化流程

```
1. tracing_subscriber — 日志初始化
2. AppConfig::from_env() — 加载配置（default.toml → local.toml → APP__* 环境变量）
3. db::create_pool() — 创建 PgPool（max 20, min 5 连接）
4. db::run_migrations() — 可选（auto_run_migrations 标志）
5. db::seed_dev_accounts() — 可选（seed_dev_accounts 标志，创建 test@example.com + admin@example.com）
6. routes::create_router() — 构建 Salvo Router 树，注入 PgPool + AppConfig
7. 预置 OpenAPI 文档端点 + Swagger UI
8. Server::new(acceptor).serve(router).await — 开始监听
```

### 11.2 路由结构（routes.rs, 359 行）

```
/api/v1/
├── health                              GET     (no auth)
├── auth/
│   ├── register                        POST    (no auth)
│   ├── learner/login                   POST    (no auth)
│   ├── admin/login                     POST    (no auth)
│   ├── refresh                         POST    (no auth)
│   └── logout                          POST    (no auth)
├── learner/                            ← JWT auth middleware
│   ├── courses/                        GET/POST
│   │   └── {course_id}/                GET/PATCH/DELETE
│   │       └── chapters/               GET/POST
│   │           └── {chapter_id}/       GET/PUT/DELETE
│   │               └── exercises/      GET/POST
│   │                   └── {exercise_id} GET/PUT/DELETE
│   ├── profile/                        GET/PATCH
│   ├── users/search                    GET
│   ├── friends/                        GET
│   │   └── requests/                   GET/POST
│   │       └── {request_id}            PATCH
│   ├── exercises/{exercise_id}         GET
│   ├── activities/                     GET
│   ├── leaderboards/                   GET
│   │   ├── friends/                    GET
│   │   └── courses/{course_id}         GET
│   ├── stats/personal                  GET
│   ├── challenges/                     GET
│   │   └── {challenge_id}/
│   │       └── attempts                POST
│   ├── daily-challenges/               GET
│   │   ├── today/                      GET
│   │   └── {id}/submit                 POST
│   ├── rewards/                        GET
│   │   ├── xp/                         GET
│   │   └── badges/                     GET
│   ├── submissions/                    POST
│   │   └── {submission_id}             GET
│   ├── ai/help/                        POST/GET
│   └── progress/                       GET/POST
│       └── courses/{course_id}         GET/PUT/DELETE
│           └── chapters/{chid}/complete POST
├── admin/                              ← JWT + require_admin middleware
│   ├── stats/{dashboard,courses,users} GET
│   ├── courses/                        GET/POST
│   │   └── {course_id}                 GET/PATCH/DELETE
│   ├── challenges/                     GET/POST
│   │   └── {challenge_id}              GET/PATCH/DELETE
│   ├── exercises/                      GET/POST
│   │   └── {exercise_id}               PATCH
│   ├── chapters/                       GET/POST
│   │   └── {chapter_id}                GET/PUT/DELETE
│   │       └── exercises/              GET/POST
│   │           └── {exercise_id}       GET/PUT/DELETE
│   ├── users/                          GET
│   │   └── {user_id}                   GET/PUT/DELETE
│   │       └── status                  PATCH
│   ├── feedback/                       GET
│   │   └── {ticket_id}                GET/PATCH
│   ├── moderation/                     GET
│   │   └── {case_id}                   GET/PATCH
│   ├── announcements/                  GET/POST
│   │   └── {announcement_id}           GET/PATCH/DELETE
│   ├── configs/                        GET/POST
│   │   └── {config_key}               GET/PATCH/DELETE
│   └── daily-challenges/               GET/POST
│       └── {id}                        GET/PUT/DELETE
└── me/                                 GET     (JWT, get current user)
```

---

## 12. 已知非标准模式

| 问题 | 位置 | 影响 | 解决方案 |
|------|------|------|---------|
| `eprintln!` 代替 `tracing` | `db.rs:21,67` | 日志不一致 | 替换为 `tracing::error!` |
| `unwrap()` 在 main.rs | `main.rs:21-22` | 可能 panic | 使用 `map_err` + 错误处理 |
| Models 单体文件（618 行） | `models.rs` | 所有领域类型在一个文件 | 考虑按领域拆分 |
| `admin.rs` 文件过大（1585 行） | `handlers/admin.rs` | 25+ 管理端点 | 考虑拆分为多个文件 |
| 配置 crate 不匹配 | `config.rs` | 代码用 `config`，文档说 `figment` | 统一文档或代码 |
| `account_service.rs` dead code | `services/account_service.rs` | `#[allow(dead_code)]` | 确认是否需要或移除 |

---

## 13. 依赖管理

### 13.1 核心依赖（Cargo.toml）

| 依赖 | 版本 | 用途 |
|------|------|------|
| **salvo** | 0.89.3 | Web 框架（affix-state, jwt-auth, test, oapi, cors） |
| **jsonwebtoken** | 9 | JWT 创建/验证 |
| **tokio** | 1 | 异步运行时 |
| **serde / serde_json** | 1 | 序列化 |
| **sqlx** | 0.8 | 数据库（pg, uuid, chrono, migrate） |
| **chrono** | 0.4 | 时间处理 |
| **uuid** | 1 | UUID v4 |
| **thiserror** | 1 | 错误推导 |
| **tracing / tracing-subscriber** | 0.1 / 0.3 | 日志 |
| **config / dotenvy** | 0.14 / 0.15 | TOML + 环境变量配置 |
| **validator** | 0.18 | 请求体验证 |
| **bcrypt** | 0.16 | 密码哈希 |
| **reqwest** | 0.12 | HTTP 客户端（AI API） |
| **tokio-retry** | 0.3 | 重试机制 |

### 13.2 测试依赖

- 69 个 tokio 测试，分属 15 个文件
- 使用 `setup_test_db()` 连接测试数据库
- 测试数据库默认为 `learning_app_test`
- 运行所有 SQLx 迁移
- 清空所有表（`TRUNCATE ... RESTART IDENTITY CASCADE`）
- 植入测试账户
