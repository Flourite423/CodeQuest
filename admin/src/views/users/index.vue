<script setup lang="ts">
import { ref, computed } from 'vue'
import { Search } from '@element-plus/icons-vue'

const users = ref([
  { id: 1, username: 'user1', phone: '13800138001', role: 'learner', status: 'active', xp: 5000 },
  { id: 2, username: 'user2', phone: '13800138002', role: 'learner', status: 'active', xp: 3200 },
  { id: 3, username: 'admin1', phone: '13800138003', role: 'admin', status: 'active', xp: 0 },
])

const searchQuery = ref('')

const filteredUsers = computed(() => {
  if (!searchQuery.value) return users.value
  return users.value.filter(u =>
    u.username.includes(searchQuery.value) ||
    u.phone.includes(searchQuery.value)
  )
})
</script>

<template>
  <div class="users">
    <div class="header">
      <h1>用户管理</h1>
      <el-input
        v-model="searchQuery"
        placeholder="搜索昵称或邮箱..."
        :prefix-icon="Search"
        style="width: 300px"
      />
    </div>

    <el-table :data="filteredUsers" style="width: 100%">
      <el-table-column prop="id" label="用户ID" width="80" />
      <el-table-column prop="username" label="昵称" />
      <el-table-column prop="phone" label="手机号" />
      <el-table-column prop="role" label="角色">
        <template #default="{ row }">
          <el-tag :type="row.role === 'admin' ? 'danger' : 'primary'">
            {{ row.role === 'admin' ? '管理员' : '学员' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="status" label="账号状态">
        <template #default="{ row }">
          <el-tag :type="row.status === 'active' ? 'success' : 'danger'">
            {{ row.status === 'active' ? '正常' : '已禁用' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="xp" label="经验值" width="100" />
      <el-table-column label="操作" width="150">
        <template #default="{ row: _row }">
          <el-button size="small">查看</el-button>
          <el-button size="small" type="danger">禁用</el-button>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<style scoped lang="scss">
.users {
  .header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;
    
    h1 {
      margin: 0;
    }
  }
}
</style>
