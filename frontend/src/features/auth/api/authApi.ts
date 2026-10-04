import { httpClient } from '@/api/httpClient'
import type { AuthResponse, LoginRequest, RegisterRequest, User } from '../types'

export const authApi = {
  login: (data: LoginRequest) => httpClient.post<AuthResponse>('/api/auth/login', data),
  register: (data: RegisterRequest) => httpClient.post<User>('/api/auth/register', data),
  me: () => httpClient.get<User>('/api/users/me'),
}
