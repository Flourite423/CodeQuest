/* eslint-disable @typescript-eslint/no-explicit-any */
import axios from 'axios'
import type { AxiosInstance } from 'axios'

const api: AxiosInstance = (axios as any).create({
  baseURL: '/api/v1',
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
})

;(api as any).interceptors.request.use(
  (config: any) => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error: any) => {
    return Promise.reject(error)
  }
)

;(api as any).interceptors.response.use(
  (response: any) => {
    return response.data
  },
  (error: any) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token')
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

export default api

export { courseApi } from './courses'
export { exerciseApi } from './exercises'
export { challengeApi } from './challenges'
export { userApi } from './users'
export { feedbackApi } from './feedback'
export { moderationApi } from './moderation'
export { announcementApi } from './announcements'
export { configApi } from './configs'
export { statsApi } from './stats'
export { authApi } from './auth'
