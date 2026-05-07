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
          meta: { title: 'Dashboard', icon: 'Odometer' },
        },
        {
          path: 'courses',
          name: 'Courses',
          component: () => import('@/views/courses/index.vue'),
          meta: { title: 'Courses', icon: 'Reading' },
        },
        {
          path: 'challenges',
          name: 'Challenges',
          component: () => import('@/views/challenges/index.vue'),
          meta: { title: 'Challenges', icon: 'Trophy' },
        },
        {
          path: 'users',
          name: 'Users',
          component: () => import('@/views/users/index.vue'),
          meta: { title: 'Users', icon: 'User' },
        },
        {
          path: 'leaderboard',
          name: 'Leaderboard',
          component: () => import('@/views/leaderboard/index.vue'),
          meta: { title: 'Leaderboard', icon: 'Medal' },
        },
        {
          path: 'moderation',
          name: 'Moderation',
          component: () => import('@/views/moderation/index.vue'),
          meta: { title: 'Moderation', icon: 'Warning' },
        },
        {
          path: 'settings',
          name: 'Settings',
          component: () => import('@/views/settings/index.vue'),
          meta: { title: 'Settings', icon: 'Setting' },
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

router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  
  if (!to.meta.public && !authStore.isAuthenticated) {
    next('/login')
  } else {
    next()
  }
})

export default router
