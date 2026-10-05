# Login Gym (Android)

App móvil Flutter homologada con el frontend web: login y registro contra el backend Spring Boot.

## Arquitectura

Capas según la guía oficial de Flutter (skill `flutter-apply-architecture-best-practices`):

```text
lib/
├── config/            # Inyección de dependencias (provider) y variables de entorno
├── data/
│   ├── models/        # Modelos de la API (freezed + json_serializable)
│   ├── repositories/  # AuthRepository: fuente única de verdad de la sesión (ChangeNotifier)
│   └── services/      # ApiClient (HTTP, devuelve Result) y almacenamiento seguro del token
├── domain/models/     # Modelos de dominio inmutables (freezed)
├── routing/           # go_router; redirige según el AuthRepository
├── ui/
│   ├── core/          # Tema, colores y widgets compartidos
│   └── features/
│       ├── auth/      # view_models/ (ChangeNotifier) + views/ (ListenableBuilder)
│       └── home/
└── utils/result.dart  # Result<T> (Ok / Failure) y AppException
```

Flujo: `View → ViewModel → Repository → Service → API`. Las vistas no conocen la API ni el token.

## Ejecutar

Requisitos: backend en `localhost:8080` y el emulador `Pixel_9_API_36` encendido.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # tras cambiar modelos freezed
flutter run                                                  # usa http://10.0.2.2:8080
flutter run --dart-define=API_URL=http://192.168.1.10:8080   # celular físico en la misma red
```

## Pruebas

```bash
flutter test                                  # repositorio, ViewModels y pantallas (sin emulador)
flutter test integration_test -d emulator-5554  # flujo completo contra el backend real
```
