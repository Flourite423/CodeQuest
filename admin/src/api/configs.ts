import api from './index'
import type {
  SuccessEnvelope,
  PaginatedResponse,
  SystemConfig,
  AdminSystemConfigUpdateInput,
  ListQueryParams,
} from '@/types'

const BASE_URL = '/admin/configs'

export const configApi = {
  list: (params?: ListQueryParams) =>
    api.get<SuccessEnvelope<PaginatedResponse<SystemConfig>>>(BASE_URL, { params }),

  update: (configKey: string, data: AdminSystemConfigUpdateInput) =>
    api.patch<SuccessEnvelope<SystemConfig>>(`${BASE_URL}/${configKey}`, data),
}
