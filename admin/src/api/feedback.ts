import api from './index'
import type {
  SuccessEnvelope,
  PaginatedResponse,
  AdminFeedbackListItem,
  ListQueryParams,
} from '@/types'

const BASE_URL = '/admin/feedback'

export const feedbackApi = {
  list: (params?: ListQueryParams) =>
    api.get<SuccessEnvelope<PaginatedResponse<AdminFeedbackListItem>>>(BASE_URL, { params }),

  reply: (ticketId: string, reply: string) =>
    api.patch<SuccessEnvelope<AdminFeedbackListItem>>(`${BASE_URL}/${ticketId}`, { admin_reply: reply }),
}
