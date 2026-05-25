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
