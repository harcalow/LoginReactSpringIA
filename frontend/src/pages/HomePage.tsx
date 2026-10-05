import { useAuth } from '@/features/auth'

export function HomePage() {
  const { user, logout } = useAuth()

  return (
    <main className="home">
      <p className="home__headline">Bienvenido, {user?.firstName}.</p>
      <p className="home__meta">
        {user?.firstName} {user?.lastName} ({user?.email})
      </p>
      <button type="button" className="button button--secondary" onClick={logout}>
        Cerrar sesión
      </button>
    </main>
  )
}
