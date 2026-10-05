import { Link } from 'react-router'

export function NotFoundPage() {
  return (
    <main className="home">
      <p className="home__headline">Esta página no existe.</p>
      <p className="home__meta">Revisa la dirección o vuelve al inicio.</p>
      <Link to="/" className="button button--primary">
        Ir al inicio
      </Link>
    </main>
  )
}
