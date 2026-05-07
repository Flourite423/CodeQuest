# Learning App Admin

基于 Vue 3 + Element Plus + Pinia 的学习应用管理后台。

## 项目结构

```
admin/
├── src/
│   ├── main.ts           # 应用入口
│   ├── App.vue           # 根组件
│   ├── router/           # 路由配置
│   │   └── index.ts
│   ├── stores/           # Pinia 状态管理
│   │   ├── auth.ts       # 认证状态
│   │   └── app.ts        # 应用状态
│   ├── api/              # API 客户端
│   │   └── index.ts
│   ├── layouts/          # 布局组件
│   │   └── default.vue   # 默认布局（侧边栏 + 顶部栏）
│   └── views/            # 页面视图
│       ├── login/        # 登录页
│       ├── dashboard/    # 仪表盘
│       ├── courses/      # 课程管理
│       ├── challenges/   # 挑战管理
│       ├── users/        # 用户管理
│       ├── leaderboard/  # 排行榜
│       ├── moderation/   # 内容审核
│       ├── settings/     # 系统设置
│       └── error/        # 错误页面
├── package.json          # 依赖配置
├── vite.config.ts        # Vite 配置
├── tsconfig.json         # TypeScript 配置
└── README.md
```

## 技术栈

- **框架**: Vue 3 (Composition API)
- **UI 组件库**: Element Plus
- **状态管理**: Pinia
- **路由**: Vue Router 4
- **构建工具**: Vite
- **HTTP 客户端**: Axios
- **样式**: SCSS

## 快速开始

### 1. 安装依赖

```bash
npm install
```

### 2. 启动开发服务器

```bash
npm run dev
```

服务将在 `http://localhost:3000` 启动。

### 3. 构建生产版本

```bash
npm run build
```

## 开发规范

1. 使用 Composition API + `<script setup>` 语法
2. 使用 TypeScript 类型注解
3. 使用 Pinia 进行状态管理
4. API 调用统一通过 `src/api/index.ts`
5. 使用 Element Plus 组件库
6. 样式使用 SCSS，组件样式加 `scoped`

## 页面说明

- **Login**: 管理员登录（用户名 + 密码）
- **Dashboard**: 数据概览、统计卡片、最近活动
- **Courses**: 课程列表、创建/编辑/删除课程
- **Challenges**: 挑战列表、创建/编辑挑战
- **Users**: 用户列表、搜索、查看详情、封禁
- **Leaderboard**: 排行榜查看
- **Moderation**: 举报处理、内容审核
- **Settings**: 系统设置

## 路由权限

- 未登录用户自动跳转到登录页
- 登录后跳转到 Dashboard
- 所有管理页面需要认证

## 契约优先

本分支遵循契约优先开发原则。所有 API 调用必须：
1. 参考 `contracts/openapi/openapi.yaml` 中的定义
2. 使用 TypeScript 类型保持前后端一致性
3. 保持与后端契约的一致性

## 环境配置

开发环境代理配置在 `vite.config.ts` 中：

```typescript
server: {
  proxy: {
    '/api': {
      target: 'http://localhost:8080',
      changeOrigin: true,
    },
  },
}
```
