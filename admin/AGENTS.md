# Admin — Vue 3 管理后台开发指南

> 面向 AI Agent 的管理后台开发规范。根目录规范见 [../AGENTS.md](../AGENTS.md)。

---

## 1. 技术栈

| 组件 | 库 |
|------|-----|
| 框架 | Vue 3 + TypeScript |
| 构建工具 | Vite |
| UI 组件库 | Element Plus |
| 状态管理 | Pinia |
| 路由 | Vue Router |
| HTTP | Axios（封装在 `src/api/`） |
| 代码规范 | ESLint + Prettier |

---

## 2. 目录结构

```
admin/src/
├── main.ts                 # 入口：创建 app → 注册插件 → mount
├── App.vue
├── api/
│   └── index.ts            # Axios 实例 + 拦截器 + 错误处理
├── stores/
│   └── index.ts            # Pinia store（用户状态、全局状态）
├── router/
│   └── index.ts            # Vue Router 配置
├── views/
│   ├── login/index.vue     # 登录页
│   └── ...                 # 其他管理页面
└── components/             # 公共组件
```

---

## 3. 开发规范

### 3.1 Vue SFC 格式

```vue
<template>
  <div class="app-container">
    <!-- Element Plus 组件 -->
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores'
import { getSomeData } from '@/api'

const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)
const dataList = ref<any[]>([])

const fetchData = async () => {
  loading.value = true
  try {
    const res = await getSomeData()
    dataList.value = res.data.items
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchData()
})
</script>

<style scoped>
.app-container {
  padding: 20px;
}
</style>
```

### 3.2 API 调用

所有 HTTP 请求通过 `src/api/index.ts` 的 Axios 实例：

```typescript
import request from '@/api'

export const getDashboardStats = () =>
  request.get('/admin/stats/dashboard')

export const getCourseList = (params: any) =>
  request.get('/admin/courses', { params })

export const createCourse = (data: any) =>
  request.post('/admin/courses', data)
```

### 3.3 路由

```typescript
// src/router/index.ts
const routes = [
  {
    path: '/login',
    component: () => import('@/views/login/index.vue'),
    hidden: true,
  },
  {
    path: '/',
    component: Layout,
    children: [
      {
        path: 'dashboard',
        component: () => import('@/views/dashboard/index.vue'),
        name: 'Dashboard',
        meta: { title: '仪表板', icon: 'dashboard' },
      },
    ],
  },
]
```

---

## 4. 快速启动

```bash
cd admin
npm install
npm run dev          # localhost:3000
npm run build        # 生产构建
npm run lint         # ESLint 检查
```

---

## 5. 与后端交互

Admin 使用独立的管理员登录接口：

```
POST /api/v1/auth/admin/login
```

管理员 JWT 带有 `role: admin`，访问 `/admin/*` 端点需要此角色。

常用管理端点：

```
GET    /api/v1/admin/stats/dashboard     仪表板统计
GET    /api/v1/admin/stats/courses        课程统计
GET    /api/v1/admin/stats/users          用户统计
GET    /api/v1/admin/courses              课程列表（管理）
POST   /api/v1/admin/courses              创建课程
PUT    /api/v1/admin/courses/{id}         更新课程
GET    /api/v1/admin/challenges           挑战列表（管理）
POST   /api/v1/admin/challenges           创建挑战
```

---

## 6. 入口点与初始化顺序

### 6.1 main.ts 初始化流程

```
1. createApp(App)
2. 注册所有 Element Plus Icons 全局
3. app.use(createPinia())
4. app.use(router)
5. app.use(ElementPlus)
6. app.mount('#app')
```

### 6.2 路由表（8 个子路由 + 1 个公开 + 1 个 catch-all）

| 路径 | 视图 | Meta/Auth |
|------|------|-----------|
| `/login` | `@/views/login/index.vue` | `public: true` |
| `/` → redirect `/dashboard` | Layout shell | 需要认证 |
| `/dashboard` | `@/views/dashboard/index.vue` | icon: Odometer |
| `/courses` | `@/views/courses/index.vue` | icon: Reading |
| `/challenges` | `@/views/challenges/index.vue` | icon: Trophy |
| `/users` | `@/views/users/index.vue` | icon: User |
| `/practice` | `@/views/practice/index.vue` | icon: EditPen |
| `/moderation` | `@/views/moderation/index.vue` | icon: Warning |
| `/feedback` | `@/views/feedback/index.vue` | icon: ChatDotRound |
| `/announcements` | `@/views/announcements/index.vue` | icon: Bell |
| `/:pathMatch(.*)*` | `@/views/error/404.vue` | — |

### 6.3 Auth Guard

`router.beforeEach` 检查 `authStore.isAuthenticated`，如果未认证则重定向到 `/login`。

---

## 7. 已知非标准模式

| 问题 | 位置 | 影响 | 解决方案 |
|------|------|------|---------|
| 过度使用 `any` 类型 | `src/api/index.ts` | 失去 TypeScript 安全性 | 添加具体类型 |
| 硬重定向 401 | `src/api/index.ts:33` | 全页面重载，破坏 SPA 导航 | 使用 `router.push('/login')` |
| 所有视图都是 `index.vue` | `src/views/*/` | 无子组件拆分 | 考虑拆分 |
| Token 在 localStorage | `src/stores/auth.ts` | 首次加载不在 Pinia store | 已在 store 创建时读取 |
| 无测试框架 | `package.json` | 0 个测试 | 添加 vitest |

---

## 8. 依赖管理

### 8.1 核心依赖（package.json）

| 依赖 | 版本 | 用途 |
|------|------|------|
| **vue** | ^3.4.0 | 框架 |
| **element-plus** | ^2.5.0 | UI 组件库 |
| **@element-plus/icons-vue** | ^2.3.1 | 图标 |
| **pinia** | ^2.1.7 | 状态管理 |
| **vue-router** | ^4.2.5 | 路由 |
| **axios** | ^1.6.5 | HTTP |
| **echarts** | ^6.1.0 | 图表 |
| **dayjs** | ^1.11.10 | 日期处理 |
| **@vueuse/core** | ^10.7.0 | 组合式工具 |
| **js-cookie / nprogress** | ^3.0 / ^0.2 | Cookie / 进度条 |
| **bcryptjs** | ^3.0.3 | 前端密码（可能用于登录页验证） |

### 8.2 开发依赖

- vite / vue-tsc / sass / prettier / eslint + TS 插件
- 构建/类型检查/样式/lint

### 8.3 测试依赖

- 0 个测试
- `package.json` 中无测试脚本（无 `jest`、`vitest`、`mocha` 等）
- 无测试目录，无测试依赖
