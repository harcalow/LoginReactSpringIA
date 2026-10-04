import { useState, type ChangeEvent, type FormEvent } from 'react'
import { ApiError } from '@/api/httpClient'
import { FormField } from '@/components/ui/FormField'
import { authApi } from '../api/authApi'
import type { RegisterRequest } from '../types'

interface RegisterFormProps {
  onSuccess: (email: string) => void
}

const EMPTY_FORM: RegisterRequest = { email: '', firstName: '', lastName: '', password: '' }

export function RegisterForm({ onSuccess }: RegisterFormProps) {
  const [values, setValues] = useState<RegisterRequest>(EMPTY_FORM)
  const [error, setError] = useState<string | null>(null)
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({})
  const [isSubmitting, setIsSubmitting] = useState(false)

  // "Guardar" solo se habilita cuando todos los campos obligatorios tienen contenido
  const isComplete = Object.values(values).every((value) => value.trim() !== '')

  function handleChange(event: ChangeEvent<HTMLInputElement>) {
    const { name, value } = event.target
    setValues((current) => ({ ...current, [name]: value }))
    setFieldErrors(({ [name]: _removed, ...rest }) => rest)
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
        value={values.email}
        onChange={handleChange}
        error={fieldErrors.email}
      />
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
      {error && (
        <p role="alert" className="auth-form__error">
          {error}
        </p>
      )}
      <button type="submit" disabled={!isComplete || isSubmitting}>
        {isSubmitting ? 'Guardando…' : 'Guardar'}
      </button>
    </form>
  )
}
