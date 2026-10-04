import { useState, type FormEvent } from 'react'
import { ApiError } from '@/api/httpClient'
import { FormField } from '@/components/ui/FormField'
import { useAuth } from '../hooks/useAuth'

interface LoginFormProps {
  defaultEmail?: string
  onSuccess: () => void
}

export function LoginForm({ defaultEmail, onSuccess }: LoginFormProps) {
  const { login } = useAuth()
  const [error, setError] = useState<string | null>(null)
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({})
  const [isSubmitting, setIsSubmitting] = useState(false)

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    const form = new FormData(event.currentTarget)
    setError(null)
    setFieldErrors({})
    setIsSubmitting(true)
    try {
      await login({
        email: String(form.get('email')),
        password: String(form.get('password')),
      })
      onSuccess()
    } catch (err) {
      if (err instanceof ApiError) {
        setError(err.message)
        setFieldErrors(err.problem.errors ?? {})
      } else {
        setError('No se pudo conectar con el servidor')
      }
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <form className="auth-form" onSubmit={handleSubmit} noValidate>
      <FormField
        label="Correo"
        name="email"
        type="email"
        autoComplete="email"
        required
        defaultValue={defaultEmail}
        error={fieldErrors.email}
      />
      <FormField
        label="Contraseña"
        name="password"
        type="password"
        autoComplete="current-password"
        required
        error={fieldErrors.password}
      />
      {error && (
        <p role="alert" className="auth-form__error">
          {error}
        </p>
      )}
      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Ingresando…' : 'Ingresar'}
      </button>
    </form>
  )
}
