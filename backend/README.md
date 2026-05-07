# Learning App Backend

基于 Salvo + SQLx + PostgreSQL 的学习应用后端服务。

## 项目结构

```
backend/
├── Cargo.toml          # Rust 项目配置
├── src/
│   ├── main.rs         # 应用入口
│   ├── config.rs       # 配置管理
│   ├── db.rs           # 数据库连接池
│   ├── models.rs       # 数据模型
│   ├── routes.rs       # 路由定义
│   ├── handlers/       # 请求处理器
│   │   ├── mod.rs
│   │   ├── auth.rs     # 认证相关
│   │   ├── course.rs   # 课程相关
│   │   ├── challenge.rs # 挑战相关
│   │   └── user.rs     # 用户相关
│   └── middleware/     # 中间件
│       ├── mod.rs
│       └── logging.rs  # 请求日志
└── config/
    ├── default.toml    # 默认配置
    └── local.toml      # 本地配置（不提交到版本控制）
```

## 技术栈

- **Web 框架**: Salvo (v0.89.3)
- **数据库**: PostgreSQL + SQLx (异步原生 SQL)
- **运行时**: Tokio
- **序列化**: Serde
- **配置**: config-rs
- **日志**: Tracing

## 快速开始

### 1. 安装依赖

确保已安装 Rust 和 PostgreSQL。

### 2. 配置环境变量

创建 `.env` 文件：

```bash
APP__SERVER_ADDR=0.0.0.0:8080
APP__DATABASE_URL=postgres://user:password@localhost/learning_app
APP__JWT_SECRET=your-secret-key
APP__JWT_EXPIRATION=86400
```

### 3. 运行数据库迁移

```bash
# 使用 sqlx-cli
sqlx migrate run
```

### 4. 启动服务

```bash
cargo run
```

服务将在 `http://0.0.0.0:8080` 启动。

## API 端点

### 健康检查
- `GET /api/v1/health` - 服务健康状态

### 认证
- `POST /api/v1/auth` - 登录（手机号 + 验证码）
- `POST /api/v1/auth/logout` - 登出
- `POST /api/v1/auth/refresh` - 刷新令牌

### 课程
- `GET /api/v1/courses` - 课程列表
- `POST /api/v1/courses` - 创建课程
- `GET /api/v1/courses/{id}` - 课程详情
- `PUT /api/v1/courses/{id}` - 更新课程
- `DELETE /api/v1/courses/{id}` - 删除课程

### 挑战
- `GET /api/v1/challenges` - 挑战列表
- `POST /api/v1/challenges` - 创建挑战
- `GET /api/v1/challenges/{id}` - 挑战详情
- `PUT /api/v1/challenges/{id}` - 更新挑战
- `DELETE /api/v1/challenges/{id}` - 删除挑战

### 用户
- `GET /api/v1/users` - 用户列表
- `GET /api/v1/users/{id}` - 用户详情
- `PUT /api/v1/users/{id}` - 更新用户

## 开发规范

1. 所有 API 响应使用统一信封格式：
   - 成功: `{ "data": ..., "meta": { "request_id": "...", "timestamp": "..." } }`
   - 错误: `{ "error": { "code": "...", "message": "..." }, "meta": { ... } }`

2. 数据库操作使用 SQLx 的编译时检查查询
3. 中间件通过 `affix_state` 注入数据库连接池
4. 错误处理使用 `StatusError` 统一返回

## 契约优先

本分支遵循契约优先开发原则。所有 API 变更必须：
1. 先更新 `contracts/openapi/openapi.yaml`
2. 通过契约审查后再修改代码
3. 保持与契约文档的一致性
