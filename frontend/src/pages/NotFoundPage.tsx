import { Link } from 'react-router'

export function NotFoundPage() {
  return (
    <main className="home-page">
      <h1>404</h1>
      <p>Página no encontrada</p>
      <Link to="/">Volver al inicio</Link>
    </main>
  )
}
