# 任务 A3 + A4: Admin 反馈管理页 + 系统配置对接

## 背景
- `admin/src/api/feedback.ts` 已定义但没有任何视图页面使用它
- `admin/src/views/announcements/index.vue` 中的"系统配置"Tab 是静态表单，未调用 `configApi`

## 目标
1. 创建反馈管理页面（A3）
2. 将系统配置改为真实 API 对接（A4）

## 修改文件

### A3: 新建 `admin/src/views/feedback/index.vue`

参考 `views/moderation/index.vue` 的风格，创建反馈管理页面：

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { Warning, RefreshRight } from '@element-plus/icons-vue'
import type { AdminFeedbackListItem, FeedbackStatus } from '@/types'
import { feedbackApi } from '@/api'
import { ElMessage, ElMessageBox } from 'element-plus'

const router = useRouter()
const loading = ref(false)
const error = ref('')
const forbidden = ref(false)
const sessionExpired = ref(false)
const activeTab = ref('pending')

const feedbackList = ref<AdminFeedbackListItem[]>([])
const replyDialogVisible = ref(false)
const replyingFeedback = ref<AdminFeedbackListItem | null>(null)
const replyContent = ref('')

const fetchData = async () => {
  loading.value = true
  error.value = ''
  forbidden.value = false
  sessionExpired.value = false
  try {
    const params = activeTab.value !== 'all' ? { status: activeTab.value } : {}
    const res = await feedbackApi.list(params)
    feedbackList.value = res.data.items
  } catch (e: unknown) {
    if (e instanceof Error && e.message.includes('403')) {
      forbidden.value = true
    } else if (e instanceof Error && e.message.includes('401')) {
      sessionExpired.value = true
      setTimeout(() => router.push('/login?expired=1'), 2000)
    } else {
      error.value = '加载数据失败，请重试'
    }
  } finally {
    loading.value = false
  }
}

const handleReply = (item: AdminFeedbackListItem) => {
  replyingFeedback.value = item
  replyContent.value = ''
  replyDialogVisible.value = true
}

const submitReply = async () => {
  if (!replyingFeedback.value || !replyContent.value.trim()) return
  try {
    await feedbackApi.reply(replyingFeedback.value.id, replyContent.value.trim())
    ElMessage.success('回复成功')
    replyDialogVisible.value = false
    fetchData()
  } catch {
    ElMessage.error('回复失败')
  }
}

const getStatusType = (status: FeedbackStatus) => {
  const map: Record<FeedbackStatus, string> = {
    pending: 'warning',
    resolved: 'success',
    closed: 'info',
  }
  return map[status] || 'info'
}

const getStatusLabel = (status: FeedbackStatus) => {
  const map: Record<FeedbackStatus, string> = {
    pending: '待处理',
    resolved: '已解决',
    closed: '已关闭',
  }
  return map[status] || status
}

fetchData()
</script>

<template>
  <div class="feedback">
    <h1>反馈管理</h1>
    <!-- 状态处理：loading / forbidden / sessionExpired / error -->
    <!-- 参考 moderation/index.vue 的模式 -->
    <template v-if="!loading && !error && !forbidden && !sessionExpired">
      <el-tabs v-model="activeTab" @tab-change="fetchData">
        <el-tab-pane label="待处理" name="pending" />
        <el-tab-pane label="已解决" name="resolved" />
        <el-tab-pane label="已关闭" name="closed" />
        <el-tab-pane label="全部" name="all" />
      </el-tabs>
      <el-empty v-if="feedbackList.length === 0" description="暂无反馈" />
      <el-table v-else :data="feedbackList" style="width: 100%">
        <el-table-column prop="title" label="标题" />
        <el-table-column prop="content" label="内容" show-overflow-tooltip />
        <el-table-column prop="learner_name" label="提交者" />
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">{{ getStatusLabel(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="created_at" label="提交时间" />
        <el-table-column label="操作" width="150">
          <template #default="{ row }">
            <el-button size="small" @click="handleReply(row)">回复</el-button>
          </template>
        </el-table-column>
      </el-table>
    </template>
    <el-dialog v-model="replyDialogVisible" title="回复反馈" width="500px">
      <el-input v-model="replyContent" type="textarea" :rows="4" placeholder="请输入回复内容" />
      <template #footer>
        <el-button @click="replyDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitReply">提交回复</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped lang="scss">
.feedback {
  h1 { margin-bottom: 24px; }
}
</style>
```

### 修改 `admin/src/router/index.ts`

添加反馈管理路由：
```typescript
{
  path: '/feedback',
  name: 'Feedback',
  component: () => import('@/views/feedback/index.vue'),
  meta: { title: '反馈管理', icon: 'ChatDotRound' },
}
```

### A4: 修改 `admin/src/views/announcements/index.vue`

将"系统配置"Tab 改为真实 API 对接：

```typescript
import { configApi } from '@/api'

// 替换静态 configForm
const configForm = ref({
  site_name: '',
  contact_email: '',
  max_courses_per_user: 10,
})
const configLoading = ref(false)

const fetchConfig = async () => {
  configLoading.value = true
  try {
    const res = await configApi.list()
    const items = res.data.items || []
    // 根据后端返回的配置项映射到表单
    const map: Record<string, any> = {}
    items.forEach((item: any) => {
      map[item.key] = item.value
    })
    configForm.value = {
      site_name: map['site_name'] || '学习平台',
      contact_email: map['contact_email'] || 'admin@example.com',
      max_courses_per_user: Number(map['max_courses_per_user'] || 10),
    }
  } catch {
    ElMessage.warning('加载配置失败，使用默认值')
  } finally {
    configLoading.value = false
  }
}

const saveConfig = async () => {
  configLoading.value = true
  try {
    const updates = [
      { key: 'site_name', value: configForm.value.site_name },
      { key: 'contact_email', value: configForm.value.contact_email },
      { key: 'max_courses_per_user', value: String(configForm.value.max_courses_per_user) },
    ]
    for (const item of updates) {
      await configApi.update(item.key, item)
    }
    ElMessage.success('配置保存成功')
  } catch {
    ElMessage.error('保存失败')
  } finally {
    configLoading.value = false
  }
}

// 在 el-tab-pane "系统配置" 的 el-form 底部：
// 将 "保存配置" 按钮的 @click 改为 @click="saveConfig"
// 添加 :loading="configLoading"
```

注意：如果 `configApi.update` 的签名是 `(key, data)` 或不同格式，请以 `admin/src/api/configs.ts` 的实际定义为准。

### 修改侧边栏菜单 `layouts/default.vue`（如需）

如果侧边栏菜单是硬编码的，需要添加"反馈管理"菜单项。

## 测试验证
- [ ] 访问 `/feedback` 正常显示反馈列表
- [ ] Tab 切换（待处理/已解决/已关闭/全部）正常工作
- [ ] 回复反馈后状态更新
- [ ] 系统配置页面加载时显示后端配置值
- [ ] 修改配置后保存成功，刷新页面值保持

## 注意
- 保持与现有管理页面一致的 UI 风格
- 错误处理参考其他页面（403/401/通用错误）
- 如果后端 API 返回数据结构不符，以前端能正常展示为准
