import { useAuth } from '@/features/auth'

export function HomePage() {
  const { user, logout } = useAuth()

  return (
    <main className="home-page">
      <h1>
        Bienvenido, {user?.firstName} {user?.lastName}
      </h1>
      <p>{user?.email}</p>
      <button type="button" onClick={logout}>
        Cerrar sesión
      </button>
    </main>
  )
}
