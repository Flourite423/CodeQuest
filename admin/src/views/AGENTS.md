# Admin Views — 管理页面开发指南

> 面向 AI Agent 的管理后台页面开发规范。上级规范见 [../../AGENTS.md](../../AGENTS.md) 和 [../AGENTS.md](../AGENTS.md)。

---

## 1. 目录结构

```
admin/src/views/
├── login/index.vue              # 登录页（唯一使用 FormRules 的页面）
├── dashboard/index.vue          # 仪表板（ECharts 图表）
├── courses/index.vue            # 课程管理（6 状态模板）
├── challenges/index.vue         # 挑战管理（6 状态模板）
├── practice/index.vue           # 练习管理（6 状态模板）
├── users/index.vue              # 用户管理（6 状态 + 抽屉详情）
├── moderation/index.vue         # 内容审核（6 状态 + 标签页）
├── feedback/index.vue           # 反馈管理（6 状态 + 标签页）
├── announcements/index.vue      # 公告管理（6 状态 + 多标签页 + 多数据源）
└── error/404.vue                # 404 页面
```

**10 个页面**，每个页面一个 `index.vue` 文件。

---

## 2. 六状态视图模板（核心模式）

**7 个数据驱动页面遵循完全相同的 6 状态渲染模式**：

```vue
<template>
  <div class="app-container">
    <h1>页面标题</h1>
    
    <!-- 状态 1：加载 -->
    <el-skeleton v-if="loading" :rows="10" animated />
    
    <!-- 状态 2：403 无权访问 -->
    <div v-else-if="forbidden" class="state-container">
      <el-icon><Lock /></el-icon>
      <p>无权访问</p>
    </div>
    
    <!-- 状态 3：401 登录过期 -->
    <div v-else-if="sessionExpired" class="state-container">
      <el-icon><Timer /></el-icon>
      <p>登录已过期</p>
      <el-button @click="goLogin">重新登录</el-button>
    </div>
    
    <!-- 状态 4：错误 -->
    <div v-else-if="error" class="state-container">
      <el-icon><CircleClose /></el-icon>
      <p>{{ errorMessage }}</p>
      <el-button @click="fetchData">重试</el-button>
    </div>
    
    <!-- 状态 5：空数据 -->
    <el-empty v-else-if="dataList.length === 0" description="暂无数据" />
    
    <!-- 状态 6：内容 -->
    <template v-else>
      <!-- 搜索/筛选栏 -->
      <!-- 数据表格 -->
      <!-- 分页 -->
    </template>
  </div>
</template>
```

**注意**：此模式在 7 个页面中大量重复，尚未抽象为布局组件或组合式函数。

---

## 3. API 调用模式

### 3.1 响应解包

Axios 实例配置为 `return response.data`，消费者直接拿到解包后的数据：

```typescript
const res = await getCourseList(params)
// res 已经是 SuccessEnvelope<T>，非 AxiosResponse
const items = res.data.items
```

### 3.2 错误检测（⚠️ 已知问题）

```typescript
// ❌ 当前模式（6 个页面中使用）
if (e instanceof Error && e.message.includes('403')) {
  forbidden.value = true
}

// ✅ 正确模式（仅 login 页面使用）
if (e.response?.status === 403) {
  forbidden.value = true
}
```

**login 页面是唯一正确使用 `e.response.status` 的页面。**

### 3.3 API 模块组织

```typescript
// api/courses.ts
const BASE_URL = '/admin/courses'

export const courseApi = {
  list: (params?) => api.get<SuccessEnvelope<PaginatedResponse<Course>>>(BASE_URL, { params }),
  create: (data) => api.post<SuccessEnvelope<CourseDetail>>(BASE_URL, data),
  update: (id, data) => api.patch<SuccessEnvelope<CourseDetail>>(`${BASE_URL}/${id}`, data),
  delete: (id) => api.delete<SuccessEnvelope<void>>(`${BASE_URL}/${id}`),
}
```

---

## 4. 状态管理

### 4.1 Auth Store

```typescript
// stores/auth.ts
export const useAuthStore = defineStore('auth', () => {
  const token = ref(localStorage.getItem('token'))  // 同步初始化
  const user = ref<{ username: string; role: string } | null>(null)
  const isAuthenticated = computed(() => !!token.value)
  
  function setToken(newToken: string) {
    token.value = newToken
    localStorage.setItem('token', newToken)  // 双重写入
  }
  
  return { token, user, isAuthenticated, setToken }
})
```

**注意**：Store 无 API 调用，登录由视图内的 `authApi.login()` 处理。

### 4.2 App Store

```typescript
// stores/app.ts
export const useAppStore = defineStore('app', () => {
  const sidebarCollapsed = ref(false)
  const theme = ref('light')  // 已定义但未使用
  return { sidebarCollapsed, theme }
})
```

---

## 5. 表单与验证

### 5.1 登录表单（唯一完整验证）

```vue
<el-form :model="form" :rules="rules">
  <el-form-item label="用户名" prop="username">
    <el-input v-model="form.username" />
  </el-form-item>
  <el-form-item label="密码" prop="password">
    <el-input v-model="form.password" type="password" />
  </el-form-item>
</el-form>
```

### 5.2 CRUD 弹窗（无验证）

```typescript
// 所有 CRUD 弹窗都使用此模式
const handleSave = async () => {
  if (!editingCourse.value) return  // 仅检查空值
  // 无表单验证
  await courseApi.update(id, editingCourse.value)
}
```

---

## 6. ECharts 使用（Dashboard）

```typescript
// ⚠️ 使用 setTimeout 延迟初始化（脆弱）
setTimeout(() => {
  chartInstance = echarts.init(chartRef.value)
  chartInstance.setOption({ ... })
}, 100)

// ✅ 正确做法：使用 nextTick() + ResizeObserver
```

---

## 7. 已知陷阱

| 问题 | 影响 | 解决方案 |
|------|------|---------|
| 6 状态模板重复 | 维护困难 | 如需提取组件，保持向后兼容 |
| 错误检测用 `message.includes` | 可能误触发 | 使用 `e.response?.status` |
| CRUD 弹窗无验证 | 数据质量 | 添加 FormRules |
| ECharts setTimeout | 初始化失败 | 使用 nextTick + ResizeObserver |
| 路由 meta 未使用 | 硬编码菜单 | 可从 route.meta 驱动 |
| SCSS 变量未使用 | 样式不一致 | 替换硬编码颜色 |
| `theme` 未使用 | 残留字段 | 移除或实现 |

---

## 8. 添加新管理页面的步骤

1. **创建文件**：`src/views/{page}/index.vue`
2. **复制 6 状态模板**：加载/403/401/错误/空/内容
3. **添加搜索/筛选栏**：使用 `el-input` + `el-button`
4. **添加数据表格**：`el-table` + `el-pagination`
5. **添加 CRUD 弹窗**：`el-dialog` + 表单
6. **创建 API 模块**：`src/api/{page}.ts`
7. **注册路由**：`src/router/index.ts`
8. **注册菜单**：`src/layouts/default.vue`（硬编码）

### 8.1 页面模板

```vue
<template>
  <div class="app-container">
    <h1>页面标题</h1>
    <el-skeleton v-if="loading" :rows="10" animated />
    <div v-else-if="forbidden" class="state-container">...</div>
    <div v-else-if="sessionExpired" class="state-container">...</div>
    <div v-else-if="error" class="state-container">...</div>
    <el-empty v-else-if="dataList.length === 0" description="暂无数据" />
    <template v-else>
      <!-- 搜索栏 -->
      <div class="header">
        <el-input v-model="searchQuery" placeholder="搜索..." />
        <el-button type="primary" @click="showCreateDialog">新增</el-button>
      </div>
      <!-- 表格 -->
      <el-table :data="dataList">
        <el-table-column prop="name" label="名称" />
        <el-table-column label="操作">
          <template #default="{ row }">
            <el-button @click="edit(row)">编辑</el-button>
            <el-button type="danger" @click="remove(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <!-- 分页 -->
      <el-pagination
        v-model:current-page="page"
        v-model:page-size="pageSize"
        :total="total"
        @change="fetchData"
      />
    </template>
    
    <!-- 弹窗 -->
    <el-dialog v-model="dialogVisible" title="编辑">
      <el-form :model="form">
        <el-form-item label="名称"><el-input v-model="form.name" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="save">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useAuthStore } from '@/stores'
import { pageApi } from '@/api'

const router = useRouter()
const authStore = useAuthStore()

// 状态
const loading = ref(false)
const forbidden = ref(false)
const sessionExpired = ref(false)
const error = ref(false)
const errorMessage = ref('')
const dataList = ref<any[]>([])
const page = ref(1)
const pageSize = ref(20)
const total = ref(0)
const searchQuery = ref('')

// 弹窗
const dialogVisible = ref(false)
const form = ref({ name: '' })
const editingId = ref('')

// 数据获取
const fetchData = async () => {
  loading.value = true
  error.value = false
  try {
    const res = await pageApi.list({
      page: page.value,
      page_size: pageSize.value,
      keyword: searchQuery.value,
    })
    dataList.value = res.data.items
    total.value = res.data.meta.total
  } catch (e: any) {
    if (e.response?.status === 403) forbidden.value = true
    else if (e.response?.status === 401) sessionExpired.value = true
    else {
      error.value = true
      errorMessage.value = e.message || '加载失败'
    }
  } finally {
    loading.value = false
  }
}

// CRUD
const showCreateDialog = () => { editingId.value = ''; form.value = { name: '' }; dialogVisible.value = true }
const edit = (row: any) => { editingId.value = row.id; form.value = { ...row }; dialogVisible.value = true }
const save = async () => {
  if (editingId.value) await pageApi.update(editingId.value, form.value)
  else await pageApi.create(form.value)
  dialogVisible.value = false
  fetchData()
  ElMessage.success('保存成功')
}
const remove = async (row: any) => {
  await ElMessageBox.confirm('确认删除？', '提示')
  await pageApi.delete(row.id)
  fetchData()
  ElMessage.success('删除成功')
}

const goLogin = () => { authStore.logout(); router.push('/login') }

onMounted(fetchData)
</script>

<style scoped lang="scss">
.app-container { padding: 20px; }
.header { display: flex; justify-content: space-between; margin-bottom: 20px; }
</style>
```

---

## 9. 已知非标准模式

| 问题 | 位置 | 影响 | 解决方案 |
|------|------|------|---------|
| 6 状态模板重复 | 7 个页面 | 维护困难 | 如需提取组件，保持向后兼容 |
| 错误检测用 `message.includes` | 6 个页面 | 可能误触发 | 使用 `e.response?.status` |
| CRUD 弹窗无验证 | 所有 CRUD 弹窗 | 数据质量 | 添加 FormRules |
| ECharts setTimeout | `dashboard/index.vue` | 初始化失败 | 使用 nextTick + ResizeObserver |
| 路由 meta 未使用 | `router/index.ts` | 硬编码菜单 | 可从 route.meta 驱动 |
| SCSS 变量未使用 | 全局样式 | 样式不一致 | 替换硬编码颜色 |
| `theme` 未使用 | `stores/app.ts` | 残留字段 | 移除或实现 |
| 过度使用 `any` 类型 | `src/api/index.ts` | 失去 TypeScript 安全性 | 添加具体类型 |
| 硬重定向 401 | `src/api/index.ts:33` | 全页面重载，破坏 SPA 导航 | 使用 `router.push('/login')` |

---

## 10. 测试依赖

- 0 个测试
- `package.json` 中无测试脚本（无 `jest`、`vitest`、`mocha` 等）
- 无测试目录，无测试依赖
