<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import type { ModerationCase } from '@/types'

const router = useRouter()
const loading = ref(false)
const error = ref('')
const forbidden = ref(false)
const sessionExpired = ref(false)

const activeTab = ref('pending')

const reports = ref<ModerationCase[]>([
  { id: 1, case_type: 'inappropriate_content', target_id: 'user2', reporter: 'user1', status: 'pending', created_at: '2024-01-15' },
  { id: 2, case_type: 'harassment', target_id: 'user4', reporter: 'user3', status: 'approved', created_at: '2024-01-14' },
  { id: 3, case_type: 'spam', target_id: 'post123', reporter: 'user5', status: 'pending', created_at: '2024-01-16' },
])

const caseTypeMap: Record<string, string> = {
  inappropriate_content: '不当内容',
  harassment: '骚扰行为',
  spam: '垃圾信息',
  cheating: '作弊行为',
  other: '其他',
}

const pendingReports = computed(() => reports.value.filter(r => r.status === 'pending'))
const processedReports = computed(() => reports.value.filter(r => r.status !== 'pending'))

const reasonDialogVisible = ref(false)
const reasonForm = ref({ action: '', reason: '' })
const currentReport = ref<ModerationCase | null>(null)

const openReasonDialog = (report: ModerationCase, action: string) => {
  currentReport.value = report
  reasonForm.value = { action, reason: '' }
  reasonDialogVisible.value = true
}

const handleConfirmAction = () => {
  if (currentReport.value && reasonForm.value.reason.trim()) {
    if (reasonForm.value.action === 'approve') {
      currentReport.value.status = 'approved'
    } else {
      currentReport.value.status = 'rejected'
    }
  }
  reasonDialogVisible.value = false
  currentReport.value = null
}

const fetchData = async () => {
  loading.value = true
  error.value = ''
  forbidden.value = false
  sessionExpired.value = false
  try {
    await new Promise(resolve => setTimeout(resolve, 500))
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

fetchData()
</script>

<template>
  <div class="moderation">
    <h1>内容审核</h1>

    <!-- Loading State -->
    <div v-if="loading" class="state-container">
      <el-skeleton :rows="5" animated />
    </div>

    <!-- Forbidden State -->
    <div v-else-if="forbidden" class="state-container">
      <el-icon class="state-icon" color="#F56C6C"><Warning /></el-icon>
      <p class="state-text">无权访问</p>
    </div>

    <!-- Session Expired State -->
    <div v-else-if="sessionExpired" class="state-container">
      <el-icon class="state-icon" color="#E6A23C"><Warning /></el-icon>
      <p class="state-text">登录已过期，请重新登录</p>
      <p class="state-subtext">正在跳转到登录页...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="state-container">
      <el-icon class="state-icon" color="#F56C6C"><Warning /></el-icon>
      <p class="state-text">{{ error }}</p>
      <el-button type="primary" @click="fetchData">重试</el-button>
    </div>

    <!-- Empty State -->
    <div v-else-if="reports.length === 0" class="state-container">
      <el-icon class="state-icon" color="#909399"><Document /></el-icon>
      <p class="state-text">暂无审核数据</p>
    </div>

    <!-- Content -->
    <template v-else>
      <el-tabs v-model="activeTab">
        <el-tab-pane label="待处理" name="pending">
          <div v-if="pendingReports.length === 0" class="state-container">
            <el-icon class="state-icon" color="#67C23A"><CircleCheck /></el-icon>
            <p class="state-text">暂无待处理举报</p>
          </div>

          <el-table v-else :data="pendingReports" style="width: 100%">
            <el-table-column prop="id" label="审核ID" width="80" />
            <el-table-column prop="case_type" label="类型">
              <template #default="{ row }">
                <el-tag>{{ caseTypeMap[row.case_type] || row.case_type }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="target_id" label="目标ID" />
            <el-table-column prop="reporter" label="举报人" />
            <el-table-column prop="created_at" label="提交时间" />
            <el-table-column label="操作" width="200">
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

        <el-tab-pane label="已处理" name="processed">
          <div v-if="processedReports.length === 0" class="state-container">
            <el-icon class="state-icon" color="#909399"><Document /></el-icon>
            <p class="state-text">暂无已处理记录</p>
          </div>

          <el-table v-else :data="processedReports" style="width: 100%">
            <el-table-column prop="id" label="审核ID" width="80" />
            <el-table-column prop="case_type" label="类型">
              <template #default="{ row }">
                <el-tag>{{ caseTypeMap[row.case_type] || row.case_type }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="target_id" label="目标ID" />
            <el-table-column prop="reporter" label="举报人" />
            <el-table-column prop="status" label="状态">
              <template #default="{ row }">
                <el-tag :type="row.status === 'approved' ? 'success' : 'danger'">
                  {{ row.status === 'approved' ? '已通过' : '已拒绝' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="created_at" label="提交时间" />
          </el-table>
        </el-tab-pane>
      </el-tabs>
    </template>

    <el-dialog
      v-model="reasonDialogVisible"
      :title="reasonForm.action === 'approve' ? '确认通过' : '确认拒绝'"
      width="400px"
    >
      <el-form :model="reasonForm">
        <el-form-item label="处理理由" required>
          <el-input
            v-model="reasonForm.reason"
            type="textarea"
            placeholder="请输入处理理由"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="reasonDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleConfirmAction">
          {{ reasonForm.action === 'approve' ? '确认通过' : '确认拒绝' }}
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
}
</style>
