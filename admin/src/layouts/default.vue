<script setup lang="ts">
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const activeMenu = computed(() => route.path)

// 中文菜单项 - 7个菜单项
const menuItems = [
  { path: '/dashboard', title: '数据看板', icon: 'Odometer' },
  { path: '/courses', title: '课程管理', icon: 'Reading' },
  { path: '/practice', title: '题目管理', icon: 'EditPen' },
  { path: '/challenges', title: '挑战管理', icon: 'Trophy' },
  { path: '/users', title: '用户管理', icon: 'User' },
  { path: '/moderation', title: '内容审核', icon: 'Warning' },
  { path: '/announcements', title: '公告与配置', icon: 'Bell' },
]

// 面包屑导航 - 根据当前路由动态生成中文路径
const breadcrumbs = computed(() => {
  const pathMap: Record<string, string> = {
    '/dashboard': '数据看板',
    '/courses': '课程管理',
    '/practice': '题目管理',
    '/challenges': '挑战管理',
    '/users': '用户管理',
    '/moderation': '内容审核',
    '/announcements': '公告与配置',
  }

  const items = [{ path: '/', title: '首页' }]
  const currentPath = route.path

  if (currentPath !== '/' && pathMap[currentPath]) {
    items.push({ path: currentPath, title: pathMap[currentPath] })
  }

  return items
})

const handleLogout = () => {
  authStore.logout()
  router.push('/login')
}
</script>

<template>
  <el-container class="layout-container">
    <!-- 侧边栏 - 宽度220px -->
    <el-aside width="220px" class="sidebar">
      <div class="logo">
        <span>前端学习平台</span>
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
      <!-- 顶部栏 - 高度60px，白色背景+阴影 -->
      <el-header class="header">
        <!-- 面包屑导航 -->
        <el-breadcrumb separator="/">
          <el-breadcrumb-item
            v-for="item in breadcrumbs"
            :key="item.path"
            :to="item.path"
          >
            {{ item.title }}
          </el-breadcrumb-item>
        </el-breadcrumb>

        <div class="header-right">
          <el-dropdown @command="handleLogout">
            <span class="user-info">
              <el-icon><User /></el-icon>
              <span>管理员</span>
              <el-icon><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="logout">退出登录</el-dropdown-item>
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
  height: 60px;
  background-color: #fff;
  box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;

  .header-right {
    .user-info {
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 8px;
      color: #606266;
      font-size: 14px;

      &:hover {
        color: #409EFF;
      }
    }
  }
}

.main-content {
  background-color: #f0f2f5;
  padding: 24px;
}
</style>
