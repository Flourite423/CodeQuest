import api from './index'
import type {
  SuccessEnvelope,
  PaginatedResponse,
  AdminUserListItem,
  AdminUserDetail,
  UpdateUserStatusInput,
  ListQueryParams,
} from '@/types'

const BASE_URL = '/admin/users'

export const userApi = {
  list: (params?: ListQueryParams) =>
    api.get<SuccessEnvelope<PaginatedResponse<AdminUserListItem>>>(BASE_URL, { params }),

  detail: (userId: string) =>
    api.get<SuccessEnvelope<AdminUserDetail>>(`${BASE_URL}/${userId}`),

  updateStatus: (userId: string, data: UpdateUserStatusInput) =>
    api.patch<SuccessEnvelope<AdminUserDetail>>(`${BASE_URL}/${userId}/status`, data),
}
