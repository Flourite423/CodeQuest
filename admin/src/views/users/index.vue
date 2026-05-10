<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { Search, Warning, Document } from '@element-plus/icons-vue'
import type { AdminUserListItem, AccountStatus } from '@/types'
import { userApi } from '@/api'
import { ElMessage } from 'element-plus'

const router = useRouter()
const loading = ref(false)
const error = ref('')
const forbidden = ref(false)
const sessionExpired = ref(false)

const users = ref<AdminUserListItem[]>([])
const searchQuery = ref('')
const statusFilter = ref('')

const drawerVisible = ref(false)
const selectedUser = ref<AdminUserListItem | null>(null)

const handleViewDetail = (user: AdminUserListItem) => {
  selectedUser.value = user
  drawerVisible.value = true
}

const handleBan = async (user: AdminUserListItem) => {
  try {
    await userApi.updateStatus(user.account_id, {
      account_status: 'suspended',
      reason: '管理员手动封禁',
    })
    ElMessage.success('封禁成功')
    fetchData()
  } catch {
    ElMessage.error('封禁失败')
  }
}

const handleUnban = async (user: AdminUserListItem) => {
  try {
    await userApi.updateStatus(user.account_id, {
      account_status: 'active',
      reason: '管理员手动解封',
    })
    ElMessage.success('解封成功')
    fetchData()
  } catch {
    ElMessage.error('解封失败')
  }
}

const getStatusType = (status: AccountStatus) => {
  const map: Record<AccountStatus, string> = {
    active: 'success',
    suspended: 'danger',
    closed: 'info',
  }
  return map[status] || 'info'
}

const getStatusLabel = (status: AccountStatus) => {
  const map: Record<AccountStatus, string> = {
    active: '正常',
    suspended: '已封禁',
    closed: '已关闭',
  }
  return map[status] || status
}

const fetchData = async () => {
  loading.value = true
  error.value = ''
  forbidden.value = false
  sessionExpired.value = false
  try {
    const params: { search?: string; status?: string } = {}
    if (searchQuery.value) params.search = searchQuery.value
    if (statusFilter.value) params.status = statusFilter.value
    
    const res = await userApi.list(params)
    users.value = res.data.items
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
      <div class="header-actions">
        <el-input
          v-model="searchQuery"
          placeholder="搜索用户..."
          :prefix-icon="Search"
          style="width: 200px; margin-right: 12px;"
          @keyup.enter="fetchData"
        />
        <el-select v-model="statusFilter" placeholder="状态筛选" style="width: 120px; margin-right: 12px;" @change="fetchData">
          <el-option label="全部" value="" />
          <el-option label="正常" value="active" />
          <el-option label="已封禁" value="suspended" />
          <el-option label="已关闭" value="closed" />
        </el-select>
        <el-button type="primary" @click="fetchData">搜索</el-button>
      </div>
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
    <div v-else-if="users.length === 0" class="state-container">
      <el-icon class="state-icon" color="#909399"><Document /></el-icon>
      <p class="state-text">暂无用户数据</p>
    </div>

    <!-- Content -->
    <template v-else>
      <el-table :data="users" style="width: 100%" v-loading="loading">
        <el-table-column prop="profile_summary.display_name" label="用户">
          <template #default="{ row }">
            <div class="user-cell">
              <el-avatar :size="32" :src="row.profile_summary.avatar_url" />
              <span>{{ row.profile_summary.display_name }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="email" label="邮箱" />
        <el-table-column prop="default_role" label="角色">
          <template #default="{ row }">
            <el-tag :type="row.default_role === 'admin' ? 'danger' : 'primary'">
              {{ row.default_role === 'admin' ? '管理员' : '学习者' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="account_status" label="状态">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.account_status)">
              {{ getStatusLabel(row.account_status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="created_at" label="注册时间" />
        <el-table-column label="操作" width="250">
          <template #default="{ row }">
            <el-button size="small" @click="handleViewDetail(row)">详情</el-button>
            <el-button 
              v-if="row.account_status === 'active'"
              size="small" 
              type="danger" 
              @click="handleBan(row)"
            >
              封禁
            </el-button>
            <el-button 
              v-else-if="row.account_status === 'suspended'"
              size="small" 
              type="success" 
              @click="handleUnban(row)"
            >
              解封
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </template>

    <el-drawer v-model="drawerVisible" title="用户详情" size="400px">
      <div v-if="selectedUser" class="user-detail">
        <div class="detail-item">
          <span class="label">用户ID：</span>
          <span>{{ selectedUser.account_id }}</span>
        </div>
        <div class="detail-item">
          <span class="label">邮箱：</span>
          <span>{{ selectedUser.email }}</span>
        </div>
        <div class="detail-item">
          <span class="label">角色：</span>
          <el-tag>{{ selectedUser.default_role === 'admin' ? '管理员' : '学习者' }}</el-tag>
        </div>
        <div class="detail-item">
          <span class="label">状态：</span>
          <el-tag :type="getStatusType(selectedUser.account_status)">
            {{ getStatusLabel(selectedUser.account_status) }}
          </el-tag>
        </div>
        <div class="detail-item">
          <span class="label">注册时间：</span>
          <span>{{ selectedUser.created_at }}</span>
        </div>
        <div class="detail-item">
          <span class="label">最后登录：</span>
          <span>{{ selectedUser.last_login_at || '从未登录' }}</span>
        </div>
      </div>
    </el-drawer>
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

  .header-actions {
    display: flex;
    align-items: center;
  }

  .user-cell {
    display: flex;
    align-items: center;
    gap: 8px;
  }
}

.user-detail {
  .detail-item {
    margin-bottom: 16px;

    .label {
      font-weight: bold;
      color: #606266;
      margin-right: 8px;
    }
  }
}
</style>
