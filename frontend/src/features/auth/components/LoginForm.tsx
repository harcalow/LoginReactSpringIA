import { useState, type ChangeEvent, type FormEvent } from 'react'
import { ApiError } from '@/api/httpClient'
import { FormField } from '@/components/ui/FormField'
import { useAuth } from '../hooks/useAuth'
import type { LoginRequest } from '../types'
import { countFilled } from '../utils/countFilled'

interface LoginFormProps {
  defaultEmail?: string
  onFilledChange: (filled: number) => void
  onSuccess: () => void
}

export function LoginForm({ defaultEmail = '', onFilledChange, onSuccess }: LoginFormProps) {
  const { login } = useAuth()
  const [values, setValues] = useState<LoginRequest>({ email: defaultEmail, password: '' })
  const [error, setError] = useState<string | null>(null)
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({})
  const [isSubmitting, setIsSubmitting] = useState(false)

  const isComplete = countFilled({ ...values }) === 2

  function handleChange(event: ChangeEvent<HTMLInputElement>) {
    const { name, value } = event.target
    const next = { ...values, [name]: value }
    setValues(next)
    setFieldErrors(({ [name]: _removed, ...rest }) => rest)
    onFilledChange(countFilled({ ...next }))
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    if (!isComplete) return
    setError(null)
    setFieldErrors({})
    setIsSubmitting(true)
    try {
      await login({ email: values.email.trim(), password: values.password })
      onSuccess()
    } catch (err) {
      if (err instanceof ApiError) {
        setError(err.message)
        setFieldErrors(err.problem.errors ?? {})
      } else {
        setError('No se pudo conectar con el servidor. Revisa tu conexión e inténtalo de nuevo.')
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
        value={values.email}
        onChange={handleChange}
        error={fieldErrors.email}
      />
      <FormField
        label="Contraseña"
        name="password"
        type="password"
        autoComplete="current-password"
        required
        value={values.password}
        onChange={handleChange}
        error={fieldErrors.password}
      />
      {error ? (
        <p role="alert" className="auth-form__error">
          {error}
        </p>
      ) : null}
      <button type="submit" className="button button--primary" disabled={!isComplete || isSubmitting}>
        {isSubmitting ? 'Ingresando…' : 'Ingresar'}
      </button>
    </form>
  )
}
