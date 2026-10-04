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
  const describedBy = [hint && hintId, error && errorId].filter(Boolean).join(' ') || undefined

  return (
    <div className="form-field">
      <label htmlFor={name}>
        {label}
        {inputProps.required && <span aria-hidden="true"> *</span>}
      </label>
      <input id={name} name={name} aria-invalid={error ? true : undefined} aria-describedby={describedBy} {...inputProps} />
      {hint && !error && (
        <span id={hintId} className="form-field__hint">
          {hint}
        </span>
      )}
      {error && (
        <span id={errorId} className="form-field__error">
          {error}
        </span>
      )}
    </div>
  )
}
