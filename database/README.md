# Base de datos

PostgreSQL 17 se levanta con `docker-compose.yml` (raíz del repo). Los datos persisten en el volumen `postgres_data`.

El **esquema** (tablas, índices) se versiona con **Flyway** en `backend/src/main/resources/db/migration`.
Nunca modifiques una migración ya aplicada: crea una nueva (`V2__...sql`).

```bash
docker compose up -d                      # PostgreSQL
docker compose --profile tools up -d      # PostgreSQL + pgAdmin (http://localhost:5050)
docker compose down                       # detiene contenedores (conserva datos)
docker compose down -v                    # detiene y BORRA los datos
```

## Docker sin Docker Desktop (Windows)

El motor Docker corre dentro de WSL2 (Ubuntu-24.04) y el `docker.exe` de Windows se conecta a él mediante
`DOCKER_HOST=tcp://127.0.0.1:2375`. Por eso **no se usan bind mounts** de carpetas locales en el compose:
el motor Linux no entiende rutas `C:\...`.
