# CodeQuest — AI Agent 开发指南

> 本文件面向 AI Coding Agent，提供项目上下文和跨端开发规范。各子项目详细规范见对应目录下的 `AGENTS.md`。

---

## 1. 项目概述

CodeQuest 是一个面向编程学习者的 **三端学习应用**：

| 端 | 技术栈 | 用途 | 端口 | 详细规范 |
|---|--------|------|------|---------|
| **Backend** | Rust + Salvo + SQLx + PostgreSQL | REST API | 3001 | [backend/AGENTS.md](backend/AGENTS.md) |
| **Mobile** | Flutter 3.x + GetX | 学习者客户端（Web / Mobile） | 8088 (web) | [mobile/AGENTS.md](mobile/AGENTS.md) |
| **Admin** | Vue 3 + Element Plus + Pinia | 管理后台 | 3000 | [admin/AGENTS.md](admin/AGENTS.md) |
| **Contracts** | OpenAPI 3.0 | API 契约层 | — | [contracts/AGENTS.md](contracts/AGENTS.md) |

**开发原则**：Contract-first —— 所有 API 变更先改 `contracts/openapi/openapi.yaml`。

---

## 2. 目录结构

```
.
├── backend/                    # Rust 后端（详见 backend/AGENTS.md）
│   ├── src/handlers/           # HTTP Handler（按领域分文件）
│   ├── src/services/           # 业务逻辑层
│   ├── src/models.rs           # 领域类型 + ApiResponse/ApiError
│   ├── src/routes.rs           # 路由总装
│   ├── migrations/             # SQLx 迁移（001~007）
│   └── config/default.toml     # 默认配置
│
├── mobile/                     # Flutter 客户端（详见 mobile/AGENTS.md）
│   ├── lib/views/              # 页面（View + Controller）
│   ├── lib/services/           # API / Storage / Progress
│   ├── lib/models/app_models.dart
│   └── lib/routes/app_pages.dart
│
├── admin/                      # Vue 3 管理后台（详见 admin/AGENTS.md）
│   ├── src/views/              # 页面组件
│   ├── src/api/                # Axios 实例
│   └── src/stores/             # Pinia
│
├── contracts/                  # 契约层（详见 contracts/AGENTS.md）
│   └── openapi/openapi.yaml    # 所有 API 变更的起点
│
├── diagrams/                   # 系统架构/ER/流程图（drawio）
├── doc/                        # 技术文档（中文）
└── thesis/                     # 毕业论文 LaTeX
```

---

## 3. 快速启动

### 3.1 后端

```bash
cd backend
cargo run                          # 开发运行
cargo build --release            # 发布构建
cargo test                       # 运行测试
cargo clippy                     # 代码检查
```

**环境变量**（前缀 `APP__`）：
```bash
export APP__SERVER_ADDR=127.0.0.1:3001
export APP__DATABASE_URL=postgres://postgres:postgres@localhost/learning_app
export APP__AUTO_RUN_MIGRATIONS=false
export APP__SEED_DEV_ACCOUNTS=false
export APP__AI__PROVIDER=mock        # mock / deepseek
```

### 3.2 Mobile（Flutter Web）

```bash
cd mobile
flutter pub get
flutter run -d chrome              # 开发运行
flutter build web --release        # 构建 Web
cd build/web && python3 -m http.server 8088   # 预览
```

### 3.3 Admin

```bash
cd admin
npm install
npm run dev        # localhost:3000
npm run build
npm run lint
```

---

## 4. 跨端修改速查

| 任务 | 文件位置 | 备注 |
|------|---------|------|
| **新增 API** | `contracts/openapi/openapi.yaml` → `backend/src/handlers/*.rs` → `backend/src/routes.rs` | Contract-first，详见 contracts/AGENTS.md |
| **新增 Backend Model** | `backend/src/models.rs` | derive Serialize, Deserialize, sqlx::FromRow |
| **新增 Handler** | `backend/src/handlers/{domain}.rs` | 不要 unwrap，返回 ApiResponse |
| **DB 查询** | Handler 文件内 | `depot.obtain::<PgPool>()` 获取 Pool |
| **修改路由** | `backend/src/routes.rs` | Salvo path 语法 `{}`，详见 backend/AGENTS.md |
| **新增 Mobile 页面** | `mobile/lib/views/{page}/` | View + Controller + Binding |
| **新增 Mobile 模型** | `mobile/lib/models/app_models.dart` | 提供 fromJson / toJson |
| **Mobile API 调用** | `mobile/lib/services/api_service.dart` | 使用 Dio，统一错误处理 |
| **Admin 页面** | `admin/src/views/{page}/` | Vue SFC + `<script setup>` |
| **Admin API** | `admin/src/api/` | Axios 实例 |

---

## 5. 通用最佳实践

- **Contract-first**：任何 API 变更必须先更新 `contracts/openapi/openapi.yaml`
- **禁止 unwrap in production**：Backend Handler 中所有 `unwrap()` 替换为 `map_err` + `StatusError`
- **注入 Pool 而非 Connection**：`depot.obtain::<PgPool>()`，不要注入单个连接
- **返回信封响应**：Backend 始终返回 `ApiResponse<T>` 或 `ApiError`，不要返回原始类型
- **测试优先**：复杂逻辑先在 `backend/tests/` 写集成测试
- **日志**：后端用 `tracing`，前端用 `debugPrint`

---

## 6. 已知陷阱（跨端）

| 问题 | 影响 | 解决方案 |
|------|------|---------|
| UUID 类型不匹配 | Backend 500 | `Uuid::parse_str()` 后再 `bind()` 到 SQL |
| 枚举与 text 比较 | Backend 500 | SQL 中用 `status::text = $2` 显式转换 |
| Daily Challenge null | 前端错误横幅 | 显式检查 `challengeRaw == null`，不要 fallback 到 data Map |
| Exercise ID vs Chapter ID | 404 导航错误 | 从 `/chapters/{id}/exercises` API 获取 exercise 列表 |
| GetStorage Web 失败 | 登录状态丢失 | 直接 `await GetStorage.init()`，不要加 timeout |
| 异步判题 score=0 | 用户体验差 | 保持同步判题，或前端轮询 submission 结果 |
