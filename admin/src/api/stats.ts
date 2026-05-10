import api from './index'
import type {
  SuccessEnvelope,
  DashboardStats,
  Activity,
} from '@/types'

export const statsApi = {
  dashboard: () =>
    api.get<SuccessEnvelope<DashboardStats>>('/admin/stats/dashboard'),

  recentActivities: () =>
    api.get<SuccessEnvelope<Activity[]>>('/admin/stats/activities'),
}
