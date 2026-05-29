# CodeQuest — AI Agent 开发指南

> 本文件面向 AI Coding Agent，提供项目上下文和跨端开发规范。各子项目详细规范见对应目录下的 `AGENTS.md`。

**Generated:** 2026-05-29
**Project Scale:** 1192 files, 285691 lines, 23 large files (>500 lines), max depth 8

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
│   ├── migrations/             # SQLx 迁移（001~008）
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

## 6. 子项目详细规范

| 子项目 | 规范文件 | 关键内容 |
|--------|----------|----------|
| **Backend** | [backend/AGENTS.md](backend/AGENTS.md) | Handler 模板、SQL 陷阱、配置说明 |
| **Backend Handlers** | [backend/src/handlers/AGENTS.md](backend/src/handlers/AGENTS.md) | Handler 函数签名、同步判题、自动复制每日挑战 |
| **Backend Services** | [backend/src/services/AGENTS.md](backend/src/services/AGENTS.md) | Service 两种风格（Struct/裸函数）、调用链 |
| **Mobile** | [mobile/AGENTS.md](mobile/AGENTS.md) | View+Controller 同文件、PageState、离线优先 |
| **Mobile Views** | [mobile/lib/views/AGENTS.md](mobile/lib/views/AGENTS.md) | 5-Tab 系统、API 解析模式、导航参数 |
| **Admin** | [admin/AGENTS.md](admin/AGENTS.md) | Vue SFC 格式、API 调用、路由 |
| **Admin Views** | [admin/src/views/AGENTS.md](admin/src/views/AGENTS.md) | 6 状态模板、ECharts、CRUD 弹窗 |
| **Contracts** | [contracts/AGENTS.md](contracts/AGENTS.md) | Contract-first、响应信封、修改步骤 |
| **OpenAPI** | [contracts/openapi/AGENTS.md](contracts/openapi/AGENTS.md) | 路径规范、Schema 命名、版本兼容规则 |

---

## 8. 配置文件清单

### 8.1 编译/构建配置

| 文件 | 层级 | 用途 |
|------|------|------|
| `backend/Cargo.toml` | Backend | Rust 包配置（edition 2021，lib+bin） |
| `backend/config/default.toml` | Backend | 默认运行时配置（figment 读取） |
| `backend/config/local.example.toml` | Backend | 本地覆盖示例 |
| `backend/.env` | Backend | 环境变量（APP__ 前缀覆盖 TOML） |
| `mobile/pubspec.yaml` | Mobile | Flutter 包配置 |
| `mobile/analysis_options.yaml` | Mobile | Dart Lint 配置 |
| `admin/package.json` | Admin | Node.js 包配置 |
| `admin/tsconfig.json` | Admin | TypeScript 编译器配置 |
| `admin/tsconfig.node.json` | Admin | Vite 配置专用 TS 配置 |
| `admin/vite.config.ts` | Admin | Vite 构建配置 |

### 8.2 代码风格/检查配置

| 文件 | 层级 | 用途 |
|------|------|------|
| `admin/.eslintrc.cjs` | Admin | ESLint + Vue3 + TypeScript |
| `mobile/analysis_options.yaml` | Mobile | Flutter Lint（继承 `flutter_lints`） |
| **无** `rustfmt.toml` | Backend | **缺失** — 使用 Rust 默认格式化 |
| **无** `clippy.toml` | Backend | **缺失** — 使用 Clippy 默认规则 |
| **无** `.prettierrc*` | Admin | **缺失** — `package.json` 有 `"format": "prettier --write src/"` 但无配置文件 |
| **无** `.editorconfig` | 根目录 | **缺失** |

### 8.3 API 契约

| 文件 | 用途 |
|------|------|
| `contracts/openapi/openapi.yaml` | OpenAPI 3.0.3 唯一真源（5800+ 行） |

---

## 9. 命名约定总览

| 概念 | Backend (Rust) | Mobile (Flutter/Dart) | Admin (Vue/TS) | OpenAPI |
|------|---------------|----------------------|----------------|---------|
| **模块/文件** | `snake_case.rs` | `snake_case.dart` | `kebab-case/` | — |
| **类/类型** | `PascalCase` | `PascalCase` | `PascalCase` | `PascalCase` |
| **函数/方法** | `snake_case` | `lowerCamelCase` | `lowerCamelCase` | — |
| **变量** | `snake_case` | `lowerCamelCase` | `lowerCamelCase` | — |
| **常量** | `SCREAMING_SNAKE_CASE` | `lowerCamelCase` | `UPPER_SNAKE_CASE` | — |
| **枚举值** | `PascalCase` (Rust) / `lower_snake_case` (SQL) | `lowerCamelCase` | `lower_snake_case` (OpenAPI) | `lower_snake_case` |
| **路由/路径** | `kebab-case` | `kebab-case` | `kebab-case` | `kebab-case` |
| **URL 参数** | `snake_case` | `snake_case` | `snake_case` | `snake_case` |
| **API 路径** | `kebab-case` / `{snake_case}` | — | — | `kebab-case` / `{snake_case}` |
| **operationId** | — | — | — | `VerbDomainResource` (PascalCase) |
| **数据库字段** | `snake_case` | — | — | `snake_case` |
| **DB 枚举值** | `lower_snake_case` | — | — | `lower_snake_case` |

---

## 10. 关键架构约束

### 10.1 Contract-First（最高优先级）
- **规则**: 任何 API 变更必须**先**更新 `contracts/openapi/openapi.yaml`
- **顺序**: OpenAPI → mock/examples → backend impl → frontend adapters → contract tests → end-to-end verify
- **禁止**: 代码实现先于契约漂移

### 10.2 响应信封
所有 API 响应使用统一格式：
```json
{
  "data": { ... },
  "meta": { "request_id": "...", "server_time": "..." }
}
```
错误格式：
```json
{
  "error": { "code": "lower_snake_case", "message": "...", "field_errors": [...], "retryable": false },
  "meta": { ... }
}
```

### 10.3 Backend 硬约束
- **禁止 unwrap**: Handler 中必须使用 `map_err` + `StatusError`
- **禁止直接 String→UUID bind**: 必须 `Uuid::parse_str` 后 bind
- **禁止注入 Connection**: 只能注入 `PgPool`
- **PostgreSQL 枚举**: 与 text 比较时使用 `enum_col::text = $2`
- **返回类型**: 始终 `Result<Json<ApiResponse<T>>, StatusError>`

### 10.4 Mobile 硬约束
- View + Controller + Binding **同文件**（`lib/views/*/*_view.dart`）
- `lib/controllers/` 中唯一文件是 `base_controller.dart`
- 使用 `PageState` 枚举管理 7 种 UI 状态
- GetStorage 初始化：`await GetStorage.init()`（不加 timeout）
- Dio + ApiService 统一封装，拦截器处理 401 跳转

### 10.5 Admin 硬约束
- 7 个数据驱动页面使用**6 状态渲染模板**（加载/403/401/错误/空数据/内容）
- Axios 实例配置为直接解包 `response.data`
- CRUD 弹窗无 FormRules 验证（已知问题）
- 错误检测推荐使用 `e.response?.status`（但 6 个页面使用 `message.includes` —— 已知偏差）

---

## 11. 已知配置缺口与偏差

| 问题 | 层级 | 严重性 | 说明 |
|------|------|--------|------|
| 无 `rustfmt.toml` | Backend | 低 | Rust 默认格式可接受，但如需团队统一可添加 |
| 无 `clippy.toml` | Backend | 低 | 依赖 Clippy 默认规则 |
| 无 `.prettierrc` | Admin | **中** | `package.json` 有 prettier 脚本但无配置文件 |
| 无 `.editorconfig` | 根目录 | **中** | 跨编辑器缩进/编码一致性缺失 |
| `eslint rule: no-explicit-any` 仅为 warn | Admin | 低 | TypeScript 类型宽松 |
| 无 `deny.toml` | Backend | 低 | 无 cargo-deny 依赖审计 |
| 无 `rust-toolchain.toml` | Backend | 低 | 未锁定 Rust 工具链版本 |
| 无包管理器 lockfile 提交 | Backend/Admin | 低 | `Cargo.lock` 在 `.gitignore` 中，`package-lock.json` 也在 `.gitignore` 中 |

---

## 12. CI/CD 现状

**项目中没有发现任何 CI/CD 基础设施**。没有 `.github/workflows/`、无 Makefile、无 docker-compose、无 Dockerfile、无 Jenkinsfile、无 GitLab CI。

### 12.1 三种独立的本地构建系统（无统一编排）

| 子系统 | 构建命令 | 构建工具 | 输出目录 | 端口 |
|--------|----------|----------|----------|------|
| Backend (Rust) | `cargo run` / `cargo build --release` | Cargo | `target/` | 3001 |
| Mobile (Flutter) | `flutter build web --release` | Flutter/Dart | `build/web/` | 8088 |
| Admin (Vue 3) | `vite build` (via `npm run build`) | Vite | `dist/` | 3000 |

### 12.2 测试覆盖率（但无 CI 执行）

**Backend（Rust）— 69 个 tokio 测试，分属 15 个文件：**
- `tests/auth_test.rs` — 10 个测试（登录/注册/刷新/登出/鉴权）
- `tests/user_test.rs` — 12 个测试（CRUD、权限、统合资料、搜索）
- `tests/contract_test.rs` — 8 个测试（OpenAPI 契约一致性验证）
- `tests/challenge_test.rs` — 6 个测试（列表/提交）
- `tests/course_test.rs` — 6 个测试（列表/详情/领取）
- 其他 10 个测试文件

**Mobile（Flutter）— 55 个测试，分属 6 个文件：**
- `shared_widgets_test.dart` — 26 个共享组件单元测试
- `page_golden_test.dart` — 13 个 Golden 快照测试
- `page_state_host_test.dart` — 10 个 PageState 组件测试
- `base_controller_test.dart` — 4 个控制器基类测试
- 其他 2 个测试文件

**Admin（Vue 3）— 0 个测试。**
`package.json` 中无测试脚本（无 `jest`、`vitest`、`mocha` 等），无测试目录，无测试依赖。

### 12.3 关键差距总结

| 能力 | 状态 | 风险等级 |
|------|------|----------|
| CI 自动化（GitHub Actions / GitLab CI） | ❌ 完全缺失 | 🔴 高 |
| Docker 容器化 | ❌ 完全缺失 | 🔴 高 |
| 统一构建编排（Makefile / Nx / Turborepo） | ❌ 完全缺失 | 🟡 中 |
| 测试自动化执行 | ❌ 完全缺失（所有测试仅本地可运行） | 🔴 高 |
| 质量门禁（lint、类型检查、覆盖率） | ❌ 完全缺失 | 🟡 中 |
| 部署流水线 | ❌ 完全缺失 | 🔴 高 |
| 发布与版本管理 | ❌ 完全缺失 | 🟡 中 |
| 预提交钩子 | ❌ 完全缺失 | 🟢 低 |
| 依赖项自动更新（Dependabot / Renovate） | ❌ 完全缺失 | 🟢 低 |
| 契约合规性自动化验证 | ⚠️ 仅后端 `contract_test.rs`（手动运行） | 🟡 中 |
| 基础设施即代码（IaC） | ❌ 完全缺失 | 🟡 中 |
| 制品管理 | ❌ 完全缺失 | 🟡 中 |
