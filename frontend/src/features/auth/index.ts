// API pública del feature: el resto de la app importa solo desde aquí.
export { AuthProvider } from './context/AuthProvider'
export { useAuth } from './hooks/useAuth'
export { LoginPage } from './pages/LoginPage'
export { RegisterPage } from './pages/RegisterPage'
export type { User, Role } from './types'
