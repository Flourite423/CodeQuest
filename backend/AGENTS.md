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
│   └── 007_extend_ai_request_type.sql
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
