<script setup lang="ts">
import { ref } from 'vue'

const loading = ref(false)
const error = ref('')

const reports = ref([
  { id: 1, case_type: 'inappropriate_content', target_id: 'user2', reporter: 'user1', status: 'pending', createdAt: '2024-01-15' },
  { id: 2, case_type: 'harassment', target_id: 'user4', reporter: 'user3', status: 'approved', createdAt: '2024-01-14' },
])

const handleApprove = (report: any) => {
  report.status = 'approved'
}

const handleReject = (report: any) => {
  report.status = 'rejected'
}

const fetchData = async () => {
  loading.value = true
  error.value = ''
  try {
    // TODO: Replace with actual API call
    await new Promise(resolve => setTimeout(resolve, 500))
  } catch (e) {
    error.value = '加载数据失败，请重试'
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
      <el-table :data="reports" style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="审核ID" width="80" />
        <el-table-column prop="case_type" label="类型">
          <template #default="{ row }">
            <el-tag>{{ row.case_type }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="target_id" label="目标ID" />
        <el-table-column prop="reporter" label="举报人" />
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">
            <el-tag :type="row.status === 'pending' ? 'warning' : row.status === 'approved' ? 'success' : 'danger'">
              {{ row.status === 'pending' ? '待处理' : row.status === 'approved' ? '已通过' : '已拒绝' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="提交时间" />
        <el-table-column label="操作" width="200">
          <template #default="{ row }">
            <el-button
              v-if="row.status === 'pending'"
              size="small"
              type="success"
              @click="handleApprove(row)"
            >
              通过
            </el-button>
            <el-button
              v-if="row.status === 'pending'"
              size="small"
              type="danger"
              @click="handleReject(row)"
            >
              拒绝
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </template>
  </div>
</template>

<style scoped lang="scss">
.moderation {
  h1 {
    margin-bottom: 24px;
  }
}
</style>
