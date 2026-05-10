import api from './index'
import type {
  SuccessEnvelope,
  PaginatedResponse,
  AdminModerationListItem,
  ModerationCase,
  UpdateModerationInput,
  ListQueryParams,
} from '@/types'

const BASE_URL = '/admin/moderation'

export const moderationApi = {
  list: (params?: ListQueryParams) =>
    api.get<SuccessEnvelope<PaginatedResponse<AdminModerationListItem>>>(BASE_URL, { params }),

  update: (caseId: string, data: UpdateModerationInput) =>
    api.patch<SuccessEnvelope<ModerationCase>>(`${BASE_URL}/${caseId}`, data),
}
