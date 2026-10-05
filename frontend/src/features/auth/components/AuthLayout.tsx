import type { ReactNode } from 'react'
import { Barbell } from './Barbell'

interface AuthLayoutProps {
  title: string
  headline: string
  tagline: string
  filled: number
  total: number
  readyText: string
  children: ReactNode
}

export function AuthLayout({ title, headline, tagline, filled, total, readyText, children }: AuthLayoutProps) {
  const loaded = Math.min(filled, total)
  const isReady = loaded === total

  return (
    <main className="auth">
      <section className="auth__stage">
        <p className="auth__headline">{headline}</p>
        <p className="auth__tagline">{tagline}</p>
        <Barbell loaded={loaded} total={total} />
        <p className="auth__progress" data-ready={isReady}>
          {isReady ? readyText : `${loaded} de ${total} discos cargados`}
        </p>
      </section>
      <section className="auth__panel">
        <div className="auth__panel-inner">
          <h1 className="auth__title">{title}</h1>
          {children}
        </div>
      </section>
    </main>
  )
}
