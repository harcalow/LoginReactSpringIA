const TOKEN_KEY = 'access_token'

// Nota: localStorage es accesible desde JS (riesgo ante XSS).
// Alternativa más segura a futuro: cookie HttpOnly emitida por el backend.
export const tokenStorage = {
  get: (): string | null => localStorage.getItem(TOKEN_KEY),
  set: (token: string) => localStorage.setItem(TOKEN_KEY, token),
  clear: () => localStorage.removeItem(TOKEN_KEY),
}
