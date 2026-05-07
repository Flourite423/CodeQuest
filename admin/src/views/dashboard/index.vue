<script setup lang="ts">
import { ref } from 'vue'

const stats = ref([
  { title: 'Total Users', value: '1,234', icon: 'User', color: '#409EFF' },
  { title: 'Total Courses', value: '56', icon: 'Reading', color: '#67C23A' },
  { title: 'Active Challenges', value: '12', icon: 'Trophy', color: '#E6A23C' },
  { title: 'Today\'s Sessions', value: '89', icon: 'View', color: '#F56C6C' },
])

const recentActivities = ref([
  { user: 'User 1', action: 'completed course', target: 'Flutter Basics', time: '2 min ago' },
  { user: 'User 2', action: 'joined challenge', target: 'Daily Coding', time: '5 min ago' },
  { user: 'User 3', action: 'earned badge', target: 'First Streak', time: '10 min ago' },
  { user: 'User 4', action: 'completed course', target: 'Rust Fundamentals', time: '15 min ago' },
  { user: 'User 5', action: 'joined challenge', target: 'Weekly Challenge', time: '20 min ago' },
])
</script>

<template>
  <div class="dashboard">
    <h1>Dashboard</h1>
    
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
        <span>Recent Activities</span>
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
