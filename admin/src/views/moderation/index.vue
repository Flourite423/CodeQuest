<script setup lang="ts">
import { ref } from 'vue'

const reports = ref([
  { id: 1, reporter: 'user1', reported: 'user2', reason: 'inappropriate_content', status: 'pending', createdAt: '2024-01-15' },
  { id: 2, reporter: 'user3', reported: 'user4', reason: 'harassment', status: 'resolved', createdAt: '2024-01-14' },
])

const handleResolve = (report: any) => {
  report.status = 'resolved'
}
</script>

<template>
  <div class="moderation">
    <h1>内容审核</h1>

    <el-table :data="reports" style="width: 100%">
      <el-table-column prop="id" label="审核ID" width="80" />
      <el-table-column prop="reporter" label="举报人" />
      <el-table-column prop="reported" label="被举报用户" />
      <el-table-column prop="reason" label="原因" />
      <el-table-column prop="status" label="状态">
        <template #default="{ row }">
          <el-tag :type="row.status === 'pending' ? 'warning' : 'success'">
            {{ row.status === 'pending' ? '待处理' : '已处理' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="createdAt" label="提交时间" />
      <el-table-column label="操作" width="150">
        <template #default="{ row }">
          <el-button 
            v-if="row.status === 'pending'"
            size="small" 
            type="success"
            @click="handleResolve(row)"
          >
            处理
          </el-button>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<style scoped lang="scss">
.moderation {
  h1 {
    margin-bottom: 24px;
  }
}
</style>
