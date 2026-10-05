import { useState } from 'react'
import { Link, Navigate, useNavigate } from 'react-router'
import { AuthLayout } from '../components/AuthLayout'
import { RegisterForm } from '../components/RegisterForm'
import { useAuth } from '../hooks/useAuth'

export function RegisterPage() {
  const { isAuthenticated } = useAuth()
  const navigate = useNavigate()
  const [filled, setFilled] = useState(0)

  if (isAuthenticated) return <Navigate to="/" replace />

  return (
    <AuthLayout
      title="Crear cuenta"
      headline="Tu primera serie empieza aquí."
      tagline="Completa tus datos: cada campo carga un disco."
      filled={filled}
      total={4}
      readyText="Barra cargada. Ya puedes guardar."
    >
      <RegisterForm
        onFilledChange={setFilled}
        onSuccess={(email) =>
          navigate('/login', {
            replace: true,
            state: { registeredEmail: email, message: '¡Cuenta creada! Ya puedes iniciar sesión.' },
          })
        }
      />
      <p className="auth__footer">
        ¿Ya tienes cuenta? <Link to="/login">Inicia sesión</Link>
      </p>
    </AuthLayout>
  )
}
