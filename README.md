# LoginReactSpringIA

Aplicación de login full-stack.

| Capa     | Tecnología                                                        | Carpeta     |
|----------|-------------------------------------------------------------------|-------------|
| Backend  | Java 21 · Spring Boot 4.1 · Spring Security (JWT) · JPA · Flyway  | `backend/`  |
| Frontend | React 19 · TypeScript · Vite · React Router                       | `frontend/` |
| BD       | PostgreSQL 17 (Docker, puerto 5433)                               | `database/` |

## Requisitos

- JDK 21
- Node.js 20+ y npm
- Docker Engine + Compose (en Windows: motor en WSL2 Ubuntu-24.04, ver [database/README.md](database/README.md))

> PostgreSQL del contenedor se publica en el puerto **5433** para no chocar con una instalación local en 5432.

## Puesta en marcha

```bash
# 1. Base de datos
cp .env.example .env
docker compose up -d

# 2. Backend  -> http://localhost:8080  (Swagger: /swagger-ui.html)
cd backend
./gradlew bootRun          # Windows: gradlew.bat bootRun

# 3. Frontend -> http://localhost:5173
cd frontend
npm install
npm run dev
```

El frontend usa el proxy de Vite (`/api` → `localhost:8080`), por lo que en desarrollo no hay problemas de CORS.

## API

| Método | Ruta                 | Auth | Descripción                    |
|--------|----------------------|------|--------------------------------|
| POST   | `/api/auth/register` | No   | Registra un usuario, retorna JWT |
| POST   | `/api/auth/login`    | No   | Autentica, retorna JWT         |
| GET    | `/api/users/me`      | Sí   | Datos del usuario autenticado  |
| GET    | `/actuator/health`   | No   | Estado del servicio            |

Los errores siguen el formato **RFC 9457 Problem Details**.

## Estructura

```
backend/src/main/java/com/loginia/backend/
├── auth/            # Login/registro: controller, service, JwtService, dto/
├── user/            # Entidad User, repositorio, /me, dto/
├── config/          # SecurityConfig, propiedades tipadas (JWT, CORS)
└── common/exception # Manejo global de errores
backend/src/main/resources/
├── application.yml  # + application-dev.yml / application-prod.yml
└── db/migration/    # Migraciones Flyway (V1__..., V2__...)

frontend/src/
├── api/             # httpClient (fetch + JWT), tokenStorage
├── components/ui/   # Componentes reutilizables
├── config/          # Variables de entorno tipadas
├── features/auth/   # Feature de autenticación (api, context, hooks, components, pages)
├── pages/           # Páginas generales (Home, 404)
└── routes/          # Router y rutas protegidas

database/            # Documentación de la BD (el esquema vive en Flyway)
```

## Configuración

- Variables del backend: ver `backend/.env.example`. En producción `JWT_SECRET` es **obligatorio**
  (`openssl rand -base64 32`) y se activa con `SPRING_PROFILES_ACTIVE=prod`.
- Variables del frontend: ver `frontend/.env.example`.
- Nunca commitear archivos `.env`.
