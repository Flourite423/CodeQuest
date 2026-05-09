<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { Search } from '@element-plus/icons-vue'
import type { User } from '@/types'

const router = useRouter()
const loading = ref(false)
const error = ref('')
const forbidden = ref(false)
const sessionExpired = ref(false)

const users = ref<User[]>([
  { id: 1, username: 'user1', email: 'user1@example.com', role: 'learner', account_status: 'active', xp: 5000 },
  { id: 2, username: 'user2', email: 'user2@example.com', role: 'learner', account_status: 'active', xp: 3200 },
  { id: 3, username: 'admin1', email: 'admin1@example.com', role: 'admin', account_status: 'active', xp: 0 },
])

const searchQuery = ref('')

const filteredUsers = computed(() => {
  if (!searchQuery.value) return users.value
  return users.value.filter(u =>
    u.username.includes(searchQuery.value) ||
    u.email.includes(searchQuery.value)
  )
})

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
    <div v-else-if="filteredUsers.length === 0" class="state-container">
      <el-icon class="state-icon" color="#909399"><User /></el-icon>
      <p class="state-text">暂无用户数据</p>
    </div>

    <!-- Content -->
    <template v-else>
      <el-table :data="filteredUsers" style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="用户ID" width="80" />
        <el-table-column prop="username" label="昵称" />
        <el-table-column prop="email" label="邮箱" />
        <el-table-column prop="role" label="角色">
          <template #default="{ row }">
            <el-tag :type="row.role === 'admin' ? 'danger' : 'primary'">
              {{ row.role === 'admin' ? '管理员' : '学员' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="account_status" label="账号状态">
          <template #default="{ row }">
            <el-tag :type="row.account_status === 'active' ? 'success' : row.account_status === 'suspended' ? 'warning' : 'danger'">
              {{ row.account_status === 'active' ? '正常' : row.account_status === 'suspended' ? '已暂停' : '已关闭' }}
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
    </template>
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
