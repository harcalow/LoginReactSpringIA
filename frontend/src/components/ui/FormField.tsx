import type { InputHTMLAttributes } from 'react'

interface FormFieldProps extends InputHTMLAttributes<HTMLInputElement> {
  label: string
  name: string
  hint?: string
  error?: string
}

export function FormField({ label, name, hint, error, ...inputProps }: FormFieldProps) {
  const hintId = `${name}-hint`
  const errorId = `${name}-error`
  const describedBy = error ? errorId : hint ? hintId : undefined

  return (
    <div className="form-field">
      <label htmlFor={name}>{label}</label>
      <input id={name} name={name} aria-invalid={error ? true : undefined} aria-describedby={describedBy} {...inputProps} />
      {error ? (
        <span id={errorId} className="form-field__error">
          {error}
        </span>
      ) : hint ? (
        <span id={hintId} className="form-field__hint">
          {hint}
        </span>
      ) : null}
    </div>
  )
}
