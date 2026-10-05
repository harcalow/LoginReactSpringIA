/// Configuración por entorno. Se sobrescribe con:
/// `flutter run --dart-define=API_URL=http://192.168.1.10:8080`
abstract final class Env {
  /// 10.0.2.2 es la IP con la que el emulador de Android llega al `localhost` del PC.
  static const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:8080');
}
