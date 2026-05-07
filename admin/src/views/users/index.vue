<script setup lang="ts">
import { ref } from 'vue'

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
      <h1>Users</h1>
      <el-input
        v-model="searchQuery"
        placeholder="Search users..."
        :prefix-icon="Search"
        style="width: 300px"
      />
    </div>

    <el-table :data="filteredUsers" style="width: 100%">
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="username" label="Username" />
      <el-table-column prop="phone" label="Phone" />
      <el-table-column prop="role" label="Role">
        <template #default="{ row }">
          <el-tag :type="row.role === 'admin' ? 'danger' : 'primary'">
            {{ row.role }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="status" label="Status">
        <template #default="{ row }">
          <el-tag :type="row.status === 'active' ? 'success' : 'danger'">
            {{ row.status }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="xp" label="XP" width="100" />
      <el-table-column label="Actions" width="150">
        <template #default="{ row }">
          <el-button size="small">View</el-button>
          <el-button size="small" type="danger">Ban</el-button>
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
