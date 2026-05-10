import api from './index'
import type {
  SuccessEnvelope,
  PaginatedResponse,
  AdminExerciseListItem,
  AdminExerciseDetail,
  ListQueryParams,
} from '@/types'

const BASE_URL = '/admin/exercises'

export const exerciseApi = {
  list: (params?: ListQueryParams) =>
    api.get<SuccessEnvelope<PaginatedResponse<AdminExerciseListItem>>>(BASE_URL, { params }),

  create: (data: Omit<AdminExerciseListItem, 'id' | 'created_at' | 'updated_at'>) =>
    api.post<SuccessEnvelope<AdminExerciseDetail>>(BASE_URL, data),

  update: (exerciseId: string, data: Partial<AdminExerciseDetail>) =>
    api.patch<SuccessEnvelope<AdminExerciseDetail>>(`${BASE_URL}/${exerciseId}`, data),

  delete: (exerciseId: string) =>
    api.delete<SuccessEnvelope<void>>(`${BASE_URL}/${exerciseId}`),
}
