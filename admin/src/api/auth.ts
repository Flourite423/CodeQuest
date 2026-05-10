import api from './index'
import type {
  SuccessEnvelope,
  LoginRequest,
  LoginResponse,
} from '@/types'

export const authApi = {
  login: (data: LoginRequest) =>
    api.post<SuccessEnvelope<LoginResponse>>('/auth/admin/login', data),
}
