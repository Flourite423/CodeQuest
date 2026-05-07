<script setup lang="ts">
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const activeMenu = computed(() => route.path)

const menuItems = [
  { path: '/dashboard', title: 'Dashboard', icon: 'Odometer' },
  { path: '/courses', title: 'Courses', icon: 'Reading' },
  { path: '/challenges', title: 'Challenges', icon: 'Trophy' },
  { path: '/users', title: 'Users', icon: 'User' },
  { path: '/leaderboard', title: 'Leaderboard', icon: 'Medal' },
  { path: '/moderation', title: 'Moderation', icon: 'Warning' },
  { path: '/settings', title: 'Settings', icon: 'Setting' },
]

const handleLogout = () => {
  authStore.logout()
  router.push('/login')
}
</script>

<template>
  <el-container class="layout-container">
    <el-aside width="200px" class="sidebar">
      <div class="logo">
        <span>Learning Admin</span>
      </div>
      <el-menu
        :default-active="activeMenu"
        router
        background-color="#304156"
        text-color="#bfcbd9"
        active-text-color="#409EFF"
      >
        <el-menu-item v-for="item in menuItems" :key="item.path" :index="item.path">
          <el-icon>
            <component :is="item.icon" />
          </el-icon>
          <span>{{ item.title }}</span>
        </el-menu-item>
      </el-menu>
    </el-aside>

    <el-container>
      <el-header class="header">
        <div class="header-right">
          <el-dropdown @command="handleLogout">
            <span class="user-info">
              <el-icon><User /></el-icon>
              Admin
              <el-icon><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="logout">Logout</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>

      <el-main class="main-content">
        <RouterView />
      </el-main>
    </el-container>
  </el-container>
</template>

<style scoped lang="scss">
.layout-container {
  height: 100vh;
}

.sidebar {
  background-color: #304156;
  
  .logo {
    height: 60px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #fff;
    font-size: 18px;
    font-weight: bold;
    border-bottom: 1px solid #1f2d3d;
  }
}

.header {
  background-color: #fff;
  box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);
  display: flex;
  align-items: center;
  justify-content: flex-end;
  
  .header-right {
    .user-info {
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 8px;
    }
  }
}

.main-content {
  background-color: #f0f2f5;
  padding: 20px;
}
</style>
