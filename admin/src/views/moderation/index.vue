<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { Warning, Document } from '@element-plus/icons-vue'
import type { AdminModerationListItem, ModerationStatus } from '@/types'
import { moderationApi } from '@/api'
import { ElMessage } from 'element-plus'

const router = useRouter()
const loading = ref(false)
const error = ref('')
const forbidden = ref(false)
const sessionExpired = ref(false)

const activeTab = ref('pending')

const reports = ref<AdminModerationListItem[]>([])

const pagination = ref({
  page: 1,
  pageSize: 10,
  total: 0,
})

const caseTypeMap: Record<string, string> = {
  nickname: '昵称违规',
  avatar: '头像违规',
  feedback: '反馈违规',
}

const pendingReports = computed(() => reports.value.filter(r => r.status === 'pending'))
const processedReports = computed(() => reports.value.filter(r => r.status !== 'pending'))

const reasonDialogVisible = ref(false)
const reasonForm = ref({ action: '', reason: '' })
const currentReport = ref<AdminModerationListItem | null>(null)

const openReasonDialog = (report: AdminModerationListItem, action: string) => {
  currentReport.value = report
  reasonForm.value = { action, reason: '' }
  reasonDialogVisible.value = true
}

const handleConfirmAction = async () => {
  if (!currentReport.value || !reasonForm.value.reason.trim()) return
  
  try {
    const status: ModerationStatus = reasonForm.value.action === 'approve' ? 'approved' : 'rejected'
    await moderationApi.update(currentReport.value.id, {
      status,
      decision_reason: reasonForm.value.reason,
    })
    ElMessage.success('操作成功')
    fetchData()
  } catch {
    ElMessage.error('操作失败')
  }
  
  reasonDialogVisible.value = false
  currentReport.value = null
}

const getStatusType = (status: ModerationStatus) => {
  const map: Record<ModerationStatus, string> = {
    pending: 'warning',
    approved: 'success',
    rejected: 'danger',
  }
  return map[status] || 'info'
}

const getStatusLabel = (status: ModerationStatus) => {
  const map: Record<ModerationStatus, string> = {
    pending: '待处理',
    approved: '已通过',
    rejected: '已拒绝',
  }
  return map[status] || status
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
    if (activeTab.value === 'pending') {
      params.status = 'pending'
    }
    const res = await moderationApi.list(params)
    reports.value = res.data.items
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
  <div class="moderation">
    <h1>内容审核</h1>

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
      v-else-if="reports.length === 0"
      class="state-container"
    >
      <el-icon
        class="state-icon"
        color="#909399"
      >
        <Document />
      </el-icon>
      <p class="state-text">
        暂无审核数据
      </p>
    </div>

    <!-- Content -->
    <template v-else>
      <el-tabs v-model="activeTab" @tab-change="handleTabChange">
        <el-tab-pane
          label="待处理"
          name="pending"
        >
          <el-table
            :data="pendingReports"
            style="width: 100%"
          >
            <el-table-column
              prop="case_type"
              label="类型"
            >
              <template #default="{ row }">
                <el-tag>{{ caseTypeMap[row.case_type] || row.case_type }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column
              prop="target_summary.target_label"
              label="目标"
            />
            <el-table-column
              prop="created_at"
              label="提交时间"
            />
            <el-table-column
              label="操作"
              width="200"
            >
              <template #default="{ row }">
                <el-button
                  size="small"
                  type="success"
                  @click="openReasonDialog(row, 'approve')"
                >
                  通过
                </el-button>
                <el-button
                  size="small"
                  type="danger"
                  @click="openReasonDialog(row, 'reject')"
                >
                  拒绝
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>

        <el-tab-pane
          label="已处理"
          name="processed"
        >
          <el-table
            :data="processedReports"
            style="width: 100%"
          >
            <el-table-column
              prop="case_type"
              label="类型"
            >
              <template #default="{ row }">
                <el-tag>{{ caseTypeMap[row.case_type] || row.case_type }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column
              prop="target_summary.target_label"
              label="目标"
            />
            <el-table-column
              prop="status"
              label="状态"
            >
              <template #default="{ row }">
                <el-tag :type="getStatusType(row.status)">
                  {{ getStatusLabel(row.status) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column
              prop="decision_reason"
              label="处理原因"
              show-overflow-tooltip
            />
            <el-table-column
              prop="reviewed_at"
              label="处理时间"
            />
          </el-table>
        </el-tab-pane>
      </el-tabs>

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
    </template>

    <el-dialog
      v-model="reasonDialogVisible"
      title="处理原因"
      width="500px"
    >
      <el-form
        :model="reasonForm"
        label-width="80px"
      >
        <el-form-item label="操作">
          <el-tag :type="reasonForm.action === 'approve' ? 'success' : 'danger'">
            {{ reasonForm.action === 'approve' ? '通过' : '拒绝' }}
          </el-tag>
        </el-form-item>
        <el-form-item label="原因">
          <el-input
            v-model="reasonForm.reason"
            type="textarea"
            :rows="3"
            placeholder="请输入处理原因..."
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="reasonDialogVisible = false">
          取消
        </el-button>
        <el-button
          type="primary"
          @click="handleConfirmAction"
        >
          确认
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped lang="scss">
.moderation {
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
