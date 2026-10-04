import { useCallback, useEffect, useMemo, useState, type ReactNode } from 'react'
import { tokenStorage } from '@/api/tokenStorage'
import { authApi } from '../api/authApi'
import type { LoginRequest, User } from '../types'
import { AuthContext, type AuthContextValue } from './AuthContext'

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [isLoading, setIsLoading] = useState(() => tokenStorage.get() !== null)

  const logout = useCallback(() => {
    tokenStorage.clear()
    setUser(null)
  }, [])

  // Restaura la sesión si hay un token guardado
  useEffect(() => {
    if (!tokenStorage.get()) return
    authApi
      .me()
      .then(setUser)
      .catch(logout)
      .finally(() => setIsLoading(false))
  }, [logout])

  // El httpClient emite este evento cuando el backend responde 401
  useEffect(() => {
    window.addEventListener('auth:logout', logout)
    return () => window.removeEventListener('auth:logout', logout)
  }, [logout])

  const login = useCallback(async (data: LoginRequest) => {
    const response = await authApi.login(data)
    tokenStorage.set(response.accessToken)
    setUser(response.user)
  }, [])

  const value = useMemo<AuthContextValue>(
    () => ({ user, isAuthenticated: user !== null, isLoading, login, logout }),
    [user, isLoading, login, logout],
  )

  return <AuthContext value={value}>{children}</AuthContext>
}
