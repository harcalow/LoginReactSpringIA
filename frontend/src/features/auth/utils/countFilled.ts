/** Cantidad de campos con contenido (ignorando espacios). Alimenta la barra de discos. */
export function countFilled(values: Record<string, string>): number {
  let count = 0
  for (const value of Object.values(values)) {
    if (value.trim() !== '') count++
  }
  return count
}
