<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { User, Reading, View, Warning } from '@element-plus/icons-vue'
import { statsApi } from '@/api'

const router = useRouter()
const loading = ref(false)
const error = ref('')
const forbidden = ref(false)
const sessionExpired = ref(false)

const stats = ref<{ title: string; value: string; icon: typeof User; color: string }[]>([
  { title: '总用户数', value: '0', icon: User, color: '#409EFF' },
  { title: '总课程数', value: '0', icon: Reading, color: '#67C23A' },
  { title: '今日活跃', value: '0', icon: View, color: '#E6A23C' },
  { title: '待审核数', value: '0', icon: Warning, color: '#F56C6C' },
])

const fetchData = async () => {
  loading.value = true
  error.value = ''
  forbidden.value = false
  sessionExpired.value = false
  try {
    const statsRes = await statsApi.dashboard()
    
    const data = statsRes.data as { total_users: number; total_courses: number; active_today: number; pending_moderation: number }
    stats.value = [
      { title: '总用户数', value: data.total_users.toLocaleString(), icon: User, color: '#409EFF' },
      { title: '总课程数', value: data.total_courses.toLocaleString(), icon: Reading, color: '#67C23A' },
      { title: '今日活跃', value: data.active_today.toLocaleString(), icon: View, color: '#E6A23C' },
      { title: '待审核数', value: data.pending_moderation.toLocaleString(), icon: Warning, color: '#F56C6C' },
    ]
    
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
  <div class="dashboard">
    <h1>数据看板</h1>

    <!-- Loading State -->
    <div
      v-if="loading"
      class="state-container"
    >
      <el-skeleton
        :rows="3"
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

    <!-- Content -->
    <template v-else>
      <el-row
        :gutter="20"
        class="stats-row"
      >
        <el-col
          v-for="stat in stats"
          :key="stat.title"
          :span="6"
        >
          <el-card class="stat-card">
            <div class="stat-content">
              <el-icon
                :size="40"
                :color="stat.color"
              >
                <component :is="stat.icon" />
              </el-icon>
              <div class="stat-info">
                <p class="stat-value">
                  {{ stat.value }}
                </p>
                <p class="stat-title">
                  {{ stat.title }}
                </p>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </template>
  </div>
</template>

<style scoped lang="scss">
.dashboard {
  h1 {
    margin-bottom: 24px;
    color: #303133;
  }
}

.stats-row {
  margin-bottom: 24px;
}

.stat-card {
  .stat-content {
    display: flex;
    align-items: center;
    gap: 16px;
  }

  .stat-info {
    .stat-value {
      font-size: 24px;
      font-weight: bold;
      color: #303133;
      margin: 0;
    }

    .stat-title {
      font-size: 14px;
      color: #909399;
      margin: 4px 0 0;
    }
  }
}

</style>
