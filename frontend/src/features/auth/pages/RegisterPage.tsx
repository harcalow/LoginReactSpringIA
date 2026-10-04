import { Link, Navigate, useNavigate } from 'react-router'
import { RegisterForm } from '../components/RegisterForm'
import { useAuth } from '../hooks/useAuth'

export function RegisterPage() {
  const { isAuthenticated } = useAuth()
  const navigate = useNavigate()

  if (isAuthenticated) return <Navigate to="/" replace />

  return (
    <main className="auth-page">
      <section className="auth-card">
        <h1>Crear cuenta</h1>
        <RegisterForm
          onSuccess={(email) =>
            navigate('/login', {
              replace: true,
              state: { registeredEmail: email, message: '¡Cuenta creada! Ya puedes iniciar sesión.' },
            })
          }
        />
        <p className="auth-card__footer">
          ¿Ya tienes cuenta? <Link to="/login">Inicia sesión</Link>
        </p>
      </section>
    </main>
  )
}
