import { Navigate, Outlet, useLocation } from 'react-router'
import { useAuth } from '@/features/auth'

export function ProtectedRoute() {
  const { isAuthenticated, isLoading } = useAuth()
  const location = useLocation()

  if (isLoading) return <p className="loading">Cargando…</p>
  if (!isAuthenticated) return <Navigate to="/login" replace state={{ from: location.pathname }} />

  return <Outlet />
}
