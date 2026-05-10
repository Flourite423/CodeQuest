import api from './index'
import type {
  SuccessEnvelope,
  PaginatedResponse,
  AdminCourseListItem,
  AdminCourseDetail,
  AdminCourseCreateInput,
  AdminCourseUpdateInput,
  ListQueryParams,
} from '@/types'

const BASE_URL = '/admin/courses'

export const courseApi = {
  list: (params?: ListQueryParams) =>
    api.get<SuccessEnvelope<PaginatedResponse<AdminCourseListItem>>>(BASE_URL, { params }),

  create: (data: AdminCourseCreateInput) =>
    api.post<SuccessEnvelope<AdminCourseDetail>>(BASE_URL, data),

  update: (courseId: string, data: AdminCourseUpdateInput) =>
    api.patch<SuccessEnvelope<AdminCourseDetail>>(`${BASE_URL}/${courseId}`, data),

  delete: (courseId: string) =>
    api.delete<SuccessEnvelope<void>>(`${BASE_URL}/${courseId}`),
}
