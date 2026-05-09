<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const loading = ref(false)
const error = ref('')
const forbidden = ref(false)
const sessionExpired = ref(false)

interface Stat {
  title: string
  value: string
  icon: string
  color: string
}

interface Activity {
  user: string
  action: string
  target: string
  time: string
}

const stats = ref<Stat[]>([
  { title: '总用户数', value: '1,234', icon: 'User', color: '#409EFF' },
  { title: '总课程数', value: '56', icon: 'Reading', color: '#67C23A' },
  { title: '今日活跃', value: '89', icon: 'View', color: '#E6A23C' },
  { title: '待审核数', value: '12', icon: 'Warning', color: '#F56C6C' },
])

const recentActivities = ref<Activity[]>([
  { user: '用户1', action: '完成了课程', target: 'Flutter 基础', time: '2 分钟前' },
  { user: '用户2', action: '加入了挑战', target: '每日编程', time: '5 分钟前' },
  { user: '用户3', action: '获得了徽章', target: '首次连胜', time: '10 分钟前' },
  { user: '用户4', action: '完成了课程', target: 'Rust 基础', time: '15 分钟前' },
  { user: '用户5', action: '加入了挑战', target: '每周挑战', time: '20 分钟前' },
])

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
  <div class="dashboard">
    <h1>数据看板</h1>

    <!-- Loading State -->
    <div v-if="loading" class="state-container">
      <el-skeleton :rows="3" animated />
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

    <!-- Content -->
    <template v-else>
      <el-row :gutter="20" class="stats-row">
        <el-col :span="6" v-for="stat in stats" :key="stat.title">
          <el-card class="stat-card">
            <div class="stat-content">
              <el-icon :size="40" :color="stat.color">
                <component :is="stat.icon" />
              </el-icon>
              <div class="stat-info">
                <p class="stat-value">{{ stat.value }}</p>
                <p class="stat-title">{{ stat.title }}</p>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <el-card class="activity-card">
        <template #header>
          <span>最近动态</span>
        </template>
        <el-timeline>
          <el-timeline-item
            v-for="(activity, index) in recentActivities"
            :key="index"
            :type="index === 0 ? 'primary' : ''"
          >
            <p>
              <strong>{{ activity.user }}</strong>
              {{ activity.action }}
              <el-tag size="small">{{ activity.target }}</el-tag>
            </p>
            <p class="activity-time">{{ activity.time }}</p>
          </el-timeline-item>
        </el-timeline>
      </el-card>
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

.activity-card {
  .activity-time {
    font-size: 12px;
    color: #909399;
    margin-top: 4px;
  }
}
</style>
