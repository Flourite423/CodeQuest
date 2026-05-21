<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { Warning, Document } from '@element-plus/icons-vue'
import type { AdminFeedbackListItem, FeedbackStatus } from '@/types'
import { feedbackApi } from '@/api'
import { ElMessage } from 'element-plus'

const router = useRouter()
const loading = ref(false)
const error = ref('')
const forbidden = ref(false)
const sessionExpired = ref(false)

const activeTab = ref('open')

const feedbackList = ref<AdminFeedbackListItem[]>([])

const pagination = ref({
  page: 1,
  pageSize: 10,
  total: 0,
})

const replyDialogVisible = ref(false)
const replyingFeedback = ref<AdminFeedbackListItem | null>(null)
const replyContent = ref('')

const statusOptions: { label: string; value: string }[] = [
  { label: '待处理', value: 'open' },
  { label: '已解决', value: 'resolved' },
  { label: '已关闭', value: 'closed' },
  { label: '全部', value: 'all' },
]

const categoryMap: Record<string, string> = {
  content: '内容问题',
  problem: '学习问题',
  bug: 'Bug反馈',
  account: '账号问题',
  other: '其他',
}

const getStatusType = (status: FeedbackStatus) => {
  const map: Record<FeedbackStatus, string> = {
    open: 'warning',
    in_progress: 'primary',
    resolved: 'success',
    closed: 'info',
  }
  return map[status] || 'info'
}

const getStatusLabel = (status: FeedbackStatus) => {
  const map: Record<FeedbackStatus, string> = {
    open: '待处理',
    in_progress: '处理中',
    resolved: '已解决',
    closed: '已关闭',
  }
  return map[status] || status
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

const fetchData = async () => {
  loading.value = true
  error.value = ''
  forbidden.value = false
  sessionExpired.value = false
  try {
    const params: Record<string, unknown> = {
      page: pagination.value.page,
      page_size: pagination.value.pageSize,
    }
    if (activeTab.value !== 'all') {
      params.status = activeTab.value
    }
    const res = await feedbackApi.list(params)
    feedbackList.value = res.data.items
    pagination.value.total = res.data.meta.total
  } catch (e: unknown) {
    if (e instanceof Error && e.message.includes('403')) {
      forbidden.value = true
    } else if (e instanceof Error && e.message.includes('401')) {
      sessionExpired.value = true
      setTimeout(() => {
        router.push('/login?expired=1')
      }, 2000)
    } else {
      error.value = '加载数据失败，请重试'
    }
  } finally {
    loading.value = false
  }
}

const handleTabChange = () => {
  pagination.value.page = 1
  fetchData()
}

fetchData()
</script>

<template>
  <div class="feedback">
    <h1>反馈管理</h1>

    <!-- Loading State -->
    <div
      v-if="loading"
      class="state-container"
    >
      <el-skeleton
        :rows="5"
        animated
      />
    </div>

    <!-- Forbidden State -->
    <div
      v-else-if="forbidden"
      class="state-container"
    >
      <el-icon
        class="state-icon"
        color="#F56C6C"
      >
        <Warning />
      </el-icon>
      <p class="state-text">
        无权访问
      </p>
    </div>

    <!-- Session Expired State -->
    <div
      v-else-if="sessionExpired"
      class="state-container"
    >
      <el-icon
        class="state-icon"
        color="#E6A23C"
      >
        <Warning />
      </el-icon>
      <p class="state-text">
        登录已过期，请重新登录
      </p>
      <p class="state-subtext">
        正在跳转到登录页...
      </p>
    </div>

    <!-- Error State -->
    <div
      v-else-if="error"
      class="state-container"
    >
      <el-icon
        class="state-icon"
        color="#F56C6C"
      >
        <Warning />
      </el-icon>
      <p class="state-text">
        {{ error }}
      </p>
      <el-button
        type="primary"
        @click="fetchData"
      >
        重试
      </el-button>
    </div>

    <!-- Empty State -->
    <div
      v-else-if="feedbackList.length === 0"
      class="state-container"
    >
      <el-icon
        class="state-icon"
        color="#909399"
      >
        <Document />
      </el-icon>
      <p class="state-text">
        暂无反馈数据
      </p>
    </div>

    <!-- Content -->
    <template v-else>
      <el-tabs
        v-model="activeTab"
        @tab-change="handleTabChange"
      >
        <el-tab-pane
          v-for="opt in statusOptions"
          :key="opt.value"
          :label="opt.label"
          :name="opt.value"
        >
          <el-table
            :data="feedbackList"
            style="width: 100%"
          >
            <el-table-column
              prop="category"
              label="分类"
              width="120"
            >
              <template #default="{ row }">
                <el-tag>{{ categoryMap[row.category] || row.category }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column
              prop="content"
              label="内容"
              show-overflow-tooltip
            />
            <el-table-column
              label="提交者"
              width="120"
            >
              <template #default="{ row }">
                {{ row.learner_profile?.nickname || '-' }}
              </template>
            </el-table-column>
            <el-table-column
              prop="status"
              label="状态"
              width="100"
            >
              <template #default="{ row }">
                <el-tag :type="getStatusType(row.status)">
                  {{ getStatusLabel(row.status) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column
              prop="admin_reply"
              label="管理员回复"
              show-overflow-tooltip
            />
            <el-table-column
              prop="created_at"
              label="提交时间"
              width="180"
            />
            <el-table-column
              label="操作"
              width="150"
            >
              <template #default="{ row }">
                <el-button
                  size="small"
                  type="primary"
                  @click="handleReply(row)"
                >
                  回复
                </el-button>
              </template>
            </el-table-column>
          </el-table>

          <div class="pagination">
            <el-pagination
              v-model:current-page="pagination.page"
              v-model:page-size="pagination.pageSize"
              :total="pagination.total"
              :page-sizes="[10, 20, 50]"
              layout="total, sizes, prev, pager, next"
              @current-change="fetchData"
              @size-change="fetchData"
            />
          </div>
        </el-tab-pane>
      </el-tabs>
    </template>

    <!-- Reply Dialog -->
    <el-dialog
      v-model="replyDialogVisible"
      title="回复反馈"
      width="500px"
    >
      <div
        v-if="replyingFeedback"
        style="margin-bottom: 16px;"
      >
        <p><strong>反馈内容：</strong>{{ replyingFeedback.content }}</p>
        <p><strong>提交者：</strong>{{ replyingFeedback.learner_profile?.nickname || '-' }}</p>
      </div>
      <el-input
        v-model="replyContent"
        type="textarea"
        :rows="4"
        placeholder="请输入回复内容..."
      />
      <template #footer>
        <el-button @click="replyDialogVisible = false">
          取消
        </el-button>
        <el-button
          type="primary"
          @click="submitReply"
        >
          提交回复
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped lang="scss">
.feedback {
  h1 {
    margin-bottom: 24px;
  }

  .pagination {
    display: flex;
    justify-content: flex-end;
    margin-top: 16px;
  }
}
</style>
