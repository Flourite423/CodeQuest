import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/login',
      name: 'Login',
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
          name: 'Dashboard',
          component: () => import('@/views/dashboard/index.vue'),
          meta: { title: '数据看板', icon: 'Odometer' },
        },
        {
          path: 'courses',
          name: 'Courses',
          component: () => import('@/views/courses/index.vue'),
          meta: { title: '课程管理', icon: 'Reading' },
        },
        {
          path: 'challenges',
          name: 'Challenges',
          component: () => import('@/views/challenges/index.vue'),
          meta: { title: '挑战管理', icon: 'Trophy' },
        },
        {
          path: 'users',
          name: 'Users',
          component: () => import('@/views/users/index.vue'),
          meta: { title: '用户管理', icon: 'User' },
        },
        {
          path: 'practice',
          name: 'Practice',
          component: () => import('@/views/practice/index.vue'),
          meta: { title: '题目管理', icon: 'EditPen' },
        },
        {
          path: 'moderation',
          name: 'Moderation',
          component: () => import('@/views/moderation/index.vue'),
          meta: { title: '内容审核', icon: 'Warning' },
        },
        {
          path: 'announcements',
          name: 'Announcements',
          component: () => import('@/views/announcements/index.vue'),
          meta: { title: '公告与配置', icon: 'Bell' },
        },
      ],
    },
    {
      path: '/:pathMatch(.*)*',
      name: 'NotFound',
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
