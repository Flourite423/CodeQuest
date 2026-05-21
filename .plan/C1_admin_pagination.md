# 任务 C1: Admin 所有列表页添加分页

## 背景
当前所有 Admin 列表页面（课程/题目/挑战/用户/审核/公告/反馈）都没有分页，一次性加载全部数据。`admin/src/types/index.ts` 中已定义 `PaginationMeta` 类型。

## 目标
为所有列表页面添加分页功能。

## 修改文件

### 1. `admin/src/types/index.ts`

确认 `PaginationMeta` 和 `PaginatedResponse` 类型定义：
```typescript
export interface PaginationMeta {
  page: number
  per_page: number
  total: number
  total_pages: number
}

export interface PaginatedResponse<T> {
  items: T[]
  meta: PaginationMeta
}
```

如果缺少，需要添加。

### 2. 各个列表页面修改

需要修改的页面：
- `views/courses/index.vue`
- `views/practice/index.vue`
- `views/challenges/index.vue`
- `views/users/index.vue`
- `views/moderation/index.vue`
- `views/announcements/index.vue`
- `views/feedback/index.vue`（如果 A3 已完成）

每个页面的修改模式类似：

#### a) 添加分页状态
```typescript
const pagination = ref({
  page: 1,
  per_page: 10,
  total: 0,
  total_pages: 0,
})
```

#### b) 修改 fetchData 传递分页参数
```typescript
const fetchData = async () => {
  loading.value = true
  try {
    const res = await courseApi.list({
      page: pagination.value.page,
      per_page: pagination.value.per_page,
      // ... 其他筛选参数
    })
    courses.value = res.data.items
    pagination.value.total = res.data.meta.total
    pagination.value.total_pages = res.data.meta.total_pages
  } catch { /* ... */ }
  finally { loading.value = false }
}
```

#### c) 添加分页组件
在 `el-table` 下方添加：
```vue
<el-pagination
  v-model:current-page="pagination.page"
  v-model:page-size="pagination.per_page"
  :total="pagination.total"
  :page-sizes="[10, 20, 50]"
  layout="total, sizes, prev, pager, next"
  @change="fetchData"
/>
```

注意：如果后端 API 还不支持分页参数，需要确认或假设 API 支持 `page` 和 `per_page` 查询参数。

### 3. API 调用修改

检查各 API 模块是否支持分页参数：
```typescript
// api/courses.ts
list: (params?: ListQueryParams) =>
  api.get<SuccessEnvelope<PaginatedResponse<Course>>>('/admin/courses', { params })
```

如果 `ListQueryParams` 缺少 `page`/`per_page`，需要扩展：
```typescript
export interface ListQueryParams {
  page?: number
  per_page?: number
  // ... 其他参数
}
```

## 测试验证
- [ ] 每个列表页面底部显示分页组件
- [ ] 切换页码正确加载对应页数据
- [ ] 切换每页条数正确刷新
- [ ] 总条目数显示正确

## 注意
- 保持各页面现有筛选/搜索功能正常工作
- 分页变化时保留当前筛选条件
- 如果后端暂不支持分页，可以先在前端做内存分页（但建议优先对接后端分页）
