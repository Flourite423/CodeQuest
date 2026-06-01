# CodeQuest

交互式前端编程学习平台，通过课程、练习、每日挑战和社交排行榜帮助学习者掌握 HTML/CSS/JavaScript。

## 技术栈

| 层 | 技术 |
|---|------|
| 后端 | Rust (Salvo + SQLx + PostgreSQL) |
| 移动端 | Flutter / Dart (GetX) |
| 管理端 | Vue 3 + TypeScript + Element Plus |

## 项目结构

```
CodeQuest/
  backend/          Rust 后端 API 服务
  mobile/           Flutter 移动客户端
  admin/            Vue 3 管理后台
  contracts/        API 合约定义、Mock 数据和请求示例
    openapi/        OpenAPI 3.1 规范
    examples/       请求/响应示例 (JSON)
    mocks/          合约测试用 Mock 数据
  doc/              项目文档（需求规格、设计文档、测试报告、用户手册、部署文档）
```

## 快速开始

### 环境要求

- Rust 1.75+
- PostgreSQL 15+
- Flutter 3.16+ / Dart 3.2+
- Node.js 18+ / npm 9+

### 后端

```bash
cd backend

# 配置环境变量
cp config/local.example.toml config/local.toml
# 编辑 config/local.toml，填入数据库连接信息

# 创建数据库
createdb learning_app

# 运行数据库迁移
cargo run -- --migrate

# (可选) 导入种子数据
psql -d learning_app -f seed_data.sql

# 启动服务
cargo run
```

服务默认监听 `http://127.0.0.1:3001`。

### 移动端

```bash
cd mobile

flutter pub get
flutter run
```

### 管理端

```bash
cd admin

npm install
npm run dev
```

管理端开发服务器默认运行在 `http://localhost:5173`，API 请求通过 Vite 代理转发到后端。

## API 概览

后端提供 72 个 RESTful 端点，主要模块：

| 模块 | 路径前缀 | 说明 |
|------|---------|------|
| 认证 | `/api/v1/auth` | 注册、登录、Token 刷新、登出 |
| 课程 | `/api/v1/learner/courses` | 课程列表、章节详情 |
| 练习 | `/api/v1/learner/exercises` | 练习详情、代码提交与判题 |
| 挑战 | `/api/v1/learner/challenges` | 挑战列表、尝试提交 |
| 每日挑战 | `/api/v1/learner/daily-challenges` | 当日挑战、提交 |
| 排行榜 | `/api/v1/learner/leaderboards` | 多维度排名 |
| 社交 | `/api/v1/learner/friends` | 好友、动态 |
| 奖励 | `/api/v1/learner/rewards` | 徽章、XP、成就 |
| AI 辅助 | `/api/v1/learner/ai-help` | 练习提示与代码分析 |
| 管理 | `/api/v1/admin/*` | 课程/练习/用户/审核/公告/反馈管理 |

完整 API 规范见 `contracts/openapi/openapi.yaml`。

## 主要功能

**学习者端 (移动端)**
- 课程浏览与学习，支持 HTML/CSS/JavaScript 三大方向
- 编程练习（在线代码编辑 + 自动判题）和单选题
- 每日挑战与限时挑战，支持星级评价
- AI 辅助提示（错误定位、修正建议、操作引导）
- 经验值、徽章、排行榜等游戏化激励
- 社交功能：好友系统、学习动态
- 离线缓存与草稿自动保存

**管理端 (Web)**
- 课程与章节管理
- 练习题管理（编程题/单选题）
- 挑战管理
- 用户管理与状态控制
- 反馈审核与内容安全审查
- 公告管理
- 系统配置与数据看板

## 部署

详见 [doc/部署文档.md](doc/部署文档.md)。

## 文档

| 文档 | 说明 |
|------|------|
| [软件需求规格说明书](doc/软件需求规格说明书.md) | 完整需求分析 |
| [软件设计文档](doc/软件设计文档.md) | 架构与模块设计 |
| [软件测试报告](doc/软件测试报告.md) | 测试用例与结果 |
| [用户手册](doc/用户手册.md) | 用户操作指南 |
| [部署文档](doc/部署文档.md) | 部署流程与配置 |

## License

MIT
