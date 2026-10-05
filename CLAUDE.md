# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Full-stack login/registration study project with two homologated frontends that share one API:

- `backend/` — Java 21, Spring Boot 4.1, Gradle (Kotlin DSL), Spring Security (stateless JWT), JPA + Flyway
- `frontend/` — React 19 + TypeScript + Vite (web)
- `mobile/` — Flutter/Dart app, Android only
- `docker-compose.yml` — PostgreSQL 17

All UI copy and backend validation messages are in Spanish.

## Commands

### Database
```bash
docker compose up -d          # PostgreSQL on localhost:5433 (NOT 5432)
```
On this Windows machine there is no Docker Desktop. Docker Engine runs inside WSL (`Ubuntu-24.04`), and the Windows `docker.exe` reaches it through `DOCKER_HOST=tcp://127.0.0.1:2375`, which is set as a user environment variable. Because the engine is Linux, **the compose file must not bind-mount Windows paths**. Port 5433 is used because a local PostgreSQL 18 Windows service already listens on 5432. To run psql: `wsl -d Ubuntu-24.04 -u root -- docker exec login-postgres psql -U loginuser -d logindb`.

### Backend (`cd backend`)
```bash
./gradlew bootRun                     # http://localhost:8080, Swagger at /swagger-ui.html (profile dev by default)
./gradlew build                       # compile + tests
./gradlew test --tests "com.loginia.backend.auth.AuthServiceTest"
./gradlew test --tests "*AuthServiceTest.registerRejectsDuplicatedEmail"
```

### Web frontend (`cd frontend`)
```bash
npm run dev       # http://localhost:5173; Vite proxies /api -> localhost:8080
npm run build     # tsc -b && vite build (this is the type-check)
npm run lint      # oxlint
```
There is no web test runner configured.

### Mobile (`cd mobile`)
The Flutter SDK is in `%USERPROFILE%\dev\flutter`. The Android SDK (command-line tools only, no Android Studio) is in `%LOCALAPPDATA%\Android\Sdk`. The emulator AVD is `Pixel_9_API_36`.
```bash
emulator -avd Pixel_9_API_36
flutter run                                          # API defaults to http://10.0.2.2:8080 (emulator -> host)
flutter run --dart-define=API_URL=http://<lan-ip>:8080
flutter analyze
flutter test                                         # unit + widget tests, no emulator needed
flutter test test/ui/auth/login_view_model_test.dart --plain-name "expone el mensaje"
flutter test integration_test -d emulator-5554       # end-to-end against the real backend (must be running)
dart run build_runner build --delete-conflicting-outputs   # after editing any @freezed / json model
```
- The generated `*.freezed.dart` and `*.g.dart` files are committed.
- `sdkmanager` now delegates to the new "Android CLI". Package names need `/` instead of `;` (e.g. `sdkmanager "ndk/28.2.13676358"`). Gradle's automatic SDK/NDK install uses the old `;` syntax and fails, so install any missing package manually.
- The connection between `flutter run` and the emulator (DDS/VM service) sometimes fails with "El equipo remoto rechazó la conexión". When that happens the app still runs, but hot reload is unavailable; retrying usually works.

## Architecture

### API contract (shared by web and mobile)
- `POST /api/auth/register` returns **201 with the user and no token**. Registering does not log the user in. Both clients go back to the login screen with the message "¡Cuenta creada! Ya puedes iniciar sesión." and the email pre-filled.
- `POST /api/auth/login` returns `{accessToken, tokenType, expiresIn, user}`.
- `GET /api/users/me` requires `Authorization: Bearer <jwt>`. Both clients use it to restore the session at startup.
- All errors are RFC 9457 `ProblemDetail`, produced by `common/exception/GlobalExceptionHandler`. Validation failures add an `errors` map (field → message). Both clients display `detail` as the general error and `errors[field]` under each input.
- User fields are `email`, `firstName`, `lastName`, `role`. Emails are trimmed and lowercased by the backend, and uniqueness is case-insensitive (DB index on `LOWER(email)`).

### Backend
- Packages are organized by feature: `auth/` (controller, `AuthService`, `JwtService`), `user/` (entity, repository, `/me`, `AppUserDetailsService`), `config/`, `common/exception/`.
- JWTs are HS256, issued and validated with Spring's own `oauth2-resource-server` Nimbus encoder/decoder, not a third-party JWT library. The `roles` claim is mapped to `ROLE_*` authorities in `SecurityConfig`.
- Configuration uses typed records `JwtProperties` (`app.security.jwt.*`) and `CorsProperties`. `application-dev.yml` contains a dev-only JWT secret; in `prod`, `JWT_SECRET` (Base64, at least 32 bytes) is required.
- The schema is owned by Flyway (`src/main/resources/db/migration`), with `ddl-auto: validate`. Never edit an applied migration; add `V<n>__*.sql` instead.

### Web frontend
- Feature-based structure: `features/auth/` exposes its public API through `index.ts`. The `@/` alias points to `src/`.
- `api/httpClient.ts` attaches the token, parses ProblemDetail into `ApiError`, and on a 401 clears the token and emits a `window` `auth:logout` event that `AuthProvider` listens to.

### Mobile
Layered architecture following the `flutter-apply-architecture-best-practices` skill. Flow: `View → ViewModel → Repository → Service → API`.
- `data/services/api_client.dart` is stateless and returns `Result<T>` (`Ok`/`Failure` with `AppException`, defined in `utils/result.dart`). It does not throw.
- `data/repositories/auth/AuthRepository` is a `ChangeNotifier` and the single source of truth for the session. `routing/router.dart` passes it as go_router's `refreshListenable`, so logging in or out triggers navigation through `redirect`, not explicit `go()` calls. A 401 during restore discards the token; a network error keeps it.
- ViewModels (`ui/features/*/view_models`) are `ChangeNotifier`s that receive repositories through their constructor. Screens create their ViewModel in `initState` with `context.read()` and render it with `ListenableBuilder`.
- Dependency injection uses `provider` and lives in `config/dependencies.dart`.
- API models (`data/models`) and domain models (`domain/models`) are separate `freezed` classes, and the repository maps between them.
- Fonts are bundled as assets (`assets/fonts`), not fetched at runtime. `BigShouldersDisplay` is a variable font, so its weight is set with `FontVariation`; see `AppTheme.display`.
- Cleartext HTTP is enabled only in `android/app/src/debug/AndroidManifest.xml`.

### Visual design (keep web and mobile in sync)
The gym/weightlifting theme is shared. Color tokens are in `frontend/src/index.css` (`:root`) and are mirrored in `mobile/lib/ui/core/themes/app_colors.dart`; change both together.

The main UI element is the "barbell": `Barbell.tsx` (SVG) and `barbell.dart`. It loads one plate per completed form field in the order red, blue, yellow, green, and lifts when every field is filled. That is also exactly when the submit button becomes enabled. Fields containing only whitespace do not count; see `countFilled` in both clients.

## Project skills
Installed in `.claude/skills/`: `frontend-design`, `vercel-react-best-practices`, `flutter-apply-architecture-best-practices`.

## Git
Work on the `dev` branch and push to `origin/dev`. `main` is the PR target.
