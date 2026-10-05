interface Plate {
  color: string
  width: number
}

// Colores reglamentarios de discos olímpicos: 25 kg, 20 kg, 15 kg y 10 kg
const PLATES: readonly Plate[] = [
  { color: 'var(--plate-red)', width: 18 },
  { color: 'var(--plate-blue)', width: 16 },
  { color: 'var(--plate-yellow)', width: 14 },
  { color: 'var(--plate-green)', width: 12 },
]

const GAP = 2
const LEFT_COLLAR = 116
const RIGHT_COLLAR = 284

interface PositionedPlate extends Plate {
  left: number
  right: number
}

function positionPlates(total: number): PositionedPlate[] {
  let offset = 0
  return PLATES.slice(0, total).map((plate) => {
    const positioned = { ...plate, left: LEFT_COLLAR - offset - plate.width, right: RIGHT_COLLAR + offset }
    offset += plate.width + GAP
    return positioned
  })
}

interface BarbellProps {
  /** Discos cargados (uno por campo completado) */
  loaded: number
  total: number
}

export function Barbell({ loaded, total }: BarbellProps) {
  const plates = positionPlates(total)
  const lifted = loaded >= total

  return (
    <div className="barbell" data-lifted={lifted}>
      <div className="barbell__lift">
        <svg viewBox="0 0 400 120" role="presentation" aria-hidden="true" focusable="false">
          <rect className="barbell__steel" x="20" y="52" width="98" height="16" rx="2" />
          <rect className="barbell__steel" x="282" y="52" width="98" height="16" rx="2" />
          <rect className="barbell__grip" x="126" y="56" width="148" height="8" rx="1" />
          <rect className="barbell__collar" x="118" y="42" width="8" height="36" rx="1" />
          <rect className="barbell__collar" x="274" y="42" width="8" height="36" rx="1" />
          {plates.map((plate, index) => {
            const isLoaded = index < loaded
            return (
              <g key={plate.color} fill={plate.color}>
                <rect
                  className="barbell__plate"
                  data-side="left"
                  data-loaded={isLoaded}
                  x={plate.left}
                  y="6"
                  width={plate.width}
                  height="108"
                  rx="3"
                />
                <rect
                  className="barbell__plate"
                  data-side="right"
                  data-loaded={isLoaded}
                  x={plate.right}
                  y="6"
                  width={plate.width}
                  height="108"
                  rx="3"
                />
              </g>
            )
          })}
        </svg>
      </div>
      <div className="barbell__shadow" />
    </div>
  )
}
