import { Link, Navigate, useLocation, useNavigate } from 'react-router'
import { LoginForm } from '../components/LoginForm'
import { useAuth } from '../hooks/useAuth'

interface LoginLocationState {
  from?: string
  message?: string
  registeredEmail?: string
}

export function LoginPage() {
  const { isAuthenticated } = useAuth()
  const navigate = useNavigate()
  const location = useLocation()
  const state = (location.state as LoginLocationState | null) ?? {}
  const from = state.from ?? '/'

  if (isAuthenticated) return <Navigate to={from} replace />

  return (
    <main className="auth-page">
      <section className="auth-card">
        <h1>Iniciar sesión</h1>
        {state.message && (
          <p role="status" className="auth-form__success">
            {state.message}
          </p>
        )}
        <LoginForm defaultEmail={state.registeredEmail} onSuccess={() => navigate(from, { replace: true })} />
        <Link to="/register" className="button button--secondary">
          Crear cuenta
        </Link>
      </section>
    </main>
  )
}
