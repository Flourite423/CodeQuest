import axios from 'axios'
import type { AxiosInstance } from 'axios'

const api: AxiosInstance = axios.create({
  baseURL: '/api/v1',
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
})

api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

api.interceptors.response.use(
  (response) => {
    return response.data
  },
  (error) => {
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
