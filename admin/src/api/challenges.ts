import api from './index'
import type {
  SuccessEnvelope,
  PaginatedResponse,
  AdminChallengeListItem,
  AdminChallengeDetail,
  ListQueryParams,
} from '@/types'

const BASE_URL = '/admin/challenges'

export const challengeApi = {
  list: (params?: ListQueryParams) =>
    api.get<SuccessEnvelope<PaginatedResponse<AdminChallengeListItem>>>(BASE_URL, { params }),

  create: (data: Omit<AdminChallengeListItem, 'id' | 'created_at' | 'updated_at'>) =>
    api.post<SuccessEnvelope<AdminChallengeDetail>>(BASE_URL, data),

  update: (challengeId: string, data: Partial<AdminChallengeDetail>) =>
    api.patch<SuccessEnvelope<AdminChallengeDetail>>(`${BASE_URL}/${challengeId}`, data),

  delete: (challengeId: string) =>
    api.delete<SuccessEnvelope<void>>(`${BASE_URL}/${challengeId}`),
}
