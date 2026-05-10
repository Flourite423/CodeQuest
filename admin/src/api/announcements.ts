import api from './index'
import type {
  SuccessEnvelope,
  PaginatedResponse,
  Announcement,
  AdminAnnouncementCreateInput,
  ListQueryParams,
} from '@/types'

const BASE_URL = '/admin/announcements'

export const announcementApi = {
  list: (params?: ListQueryParams) =>
    api.get<SuccessEnvelope<PaginatedResponse<Announcement>>>(BASE_URL, { params }),

  create: (data: AdminAnnouncementCreateInput) =>
    api.post<SuccessEnvelope<Announcement>>(BASE_URL, data),

  update: (announcementId: string, data: Partial<AdminAnnouncementCreateInput>) =>
    api.patch<SuccessEnvelope<Announcement>>(`${BASE_URL}/${announcementId}`, data),

  delete: (announcementId: string) =>
    api.delete<SuccessEnvelope<void>>(`${BASE_URL}/${announcementId}`),
}
