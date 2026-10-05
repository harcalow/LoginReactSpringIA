import { useState, type ChangeEvent, type FormEvent } from 'react'
import { ApiError } from '@/api/httpClient'
import { FormField } from '@/components/ui/FormField'
import { authApi } from '../api/authApi'
import type { RegisterRequest } from '../types'
import { countFilled } from '../utils/countFilled'

interface RegisterFormProps {
  onFilledChange: (filled: number) => void
  onSuccess: (email: string) => void
}

const EMPTY_FORM: RegisterRequest = { email: '', firstName: '', lastName: '', password: '' }
const TOTAL_FIELDS = Object.keys(EMPTY_FORM).length

export function RegisterForm({ onFilledChange, onSuccess }: RegisterFormProps) {
  const [values, setValues] = useState<RegisterRequest>(EMPTY_FORM)
  const [error, setError] = useState<string | null>(null)
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({})
  const [isSubmitting, setIsSubmitting] = useState(false)

  // "Guardar" solo se habilita cuando todos los campos obligatorios tienen contenido
  const isComplete = countFilled({ ...values }) === TOTAL_FIELDS

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
      const user = await authApi.register({
        email: values.email.trim(),
        firstName: values.firstName.trim(),
        lastName: values.lastName.trim(),
        password: values.password,
      })
      onSuccess(user.email)
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
      <div className="auth-form__row">
        <FormField
          label="Nombres"
          name="firstName"
          autoComplete="given-name"
          required
          maxLength={60}
          value={values.firstName}
          onChange={handleChange}
          error={fieldErrors.firstName}
        />
        <FormField
          label="Apellidos"
          name="lastName"
          autoComplete="family-name"
          required
          maxLength={60}
          value={values.lastName}
          onChange={handleChange}
          error={fieldErrors.lastName}
        />
      </div>
      <FormField
        label="Contraseña"
        name="password"
        type="password"
        autoComplete="new-password"
        required
        maxLength={72}
        hint="Mínimo 8 caracteres"
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
        {isSubmitting ? 'Guardando…' : 'Guardar'}
      </button>
    </form>
  )
}
