import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/login',
      name: '登录',
      component: () => import('@/views/login/index.vue'),
      meta: { public: true },
    },
    {
      path: '/',
      component: () => import('@/layouts/default.vue'),
      redirect: '/dashboard',
      children: [
        {
          path: 'dashboard',
          name: '数据看板',
          component: () => import('@/views/dashboard/index.vue'),
          meta: { title: '数据看板', icon: 'Odometer' },
        },
        {
          path: 'courses',
          name: '课程管理',
          component: () => import('@/views/courses/index.vue'),
          meta: { title: '课程管理', icon: 'Reading' },
        },
        {
          path: 'challenges',
          name: '挑战管理',
          component: () => import('@/views/challenges/index.vue'),
          meta: { title: '挑战管理', icon: 'Trophy' },
        },
        {
          path: 'users',
          name: '用户管理',
          component: () => import('@/views/users/index.vue'),
          meta: { title: '用户管理', icon: 'User' },
        },
        {
          path: 'practice',
          name: '题目管理',
          component: () => import('@/views/practice/index.vue'),
          meta: { title: '题目管理', icon: 'EditPen' },
        },
        {
          path: 'moderation',
          name: '内容审核',
          component: () => import('@/views/moderation/index.vue'),
          meta: { title: '内容审核', icon: 'Warning' },
        },
        {
          path: 'feedback',
          name: '反馈管理',
          component: () => import('@/views/feedback/index.vue'),
          meta: { title: '反馈管理', icon: 'ChatDotRound' },
        },
        {
          path: 'announcements',
          name: '公告与配置',
          component: () => import('@/views/announcements/index.vue'),
          meta: { title: '公告与配置', icon: 'Bell' },
        },
      ],
    },
    {
      path: '/:pathMatch(.*)*',
      name: '页面未找到',
      component: () => import('@/views/error/404.vue'),
    },
  ],
})

router.beforeEach((to, _from, next) => {
  const authStore = useAuthStore()
  
  if (!to.meta.public && !authStore.isAuthenticated) {
    next('/login')
  } else {
    next()
  }
})

export default router
