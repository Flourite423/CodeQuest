/* eslint-disable @typescript-eslint/no-explicit-any */
import axios from 'axios'
import type { AxiosInstance } from 'axios'
import { resolveMockApiResponse } from './mock'

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
    const errorMessage = typeof error?.message === 'string' ? error.message : ''
    const status = error?.response?.status
    const shouldUseMock =
      error?.code === 'ERR_NETWORK' ||
      errorMessage.includes('ERR_CONNECTION_REFUSED') ||
      (status >= 500 && status <= 599) ||
      status === 0

    if (shouldUseMock) {
      const mockResponse = resolveMockApiResponse(error?.config ?? {})
      if (mockResponse) {
        return Promise.resolve(mockResponse)
      }
    }

    if (status === 401) {
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
