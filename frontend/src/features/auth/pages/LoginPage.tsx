import { useState } from 'react'
import { Link, Navigate, useLocation, useNavigate } from 'react-router'
import { AuthLayout } from '../components/AuthLayout'
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
  const [filled, setFilled] = useState(() => (state.registeredEmail ? 1 : 0))

  if (isAuthenticated) return <Navigate to={from} replace />

  return (
    <AuthLayout
      title="Iniciar sesión"
      headline="Hoy también se entrena."
      tagline="Inicia sesión para seguir con tu plan."
      filled={filled}
      total={2}
      readyText="Barra cargada. Ya puedes ingresar."
    >
      {state.message ? (
        <p role="status" className="auth-form__success">
          {state.message}
        </p>
      ) : null}
      <LoginForm
        defaultEmail={state.registeredEmail}
        onFilledChange={setFilled}
        onSuccess={() => navigate(from, { replace: true })}
      />
      <div className="auth__switch">
        <span>¿Aún no tienes cuenta?</span>
        <Link to="/register" className="button button--secondary">
          Crear cuenta
        </Link>
      </div>
    </AuthLayout>
  )
}
