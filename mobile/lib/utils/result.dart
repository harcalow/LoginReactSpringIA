/// Resultado de una operación que puede fallar, sin usar excepciones como flujo de control.
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;

  const factory Result.failure(AppException error) = Failure<T>;
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);

  final AppException error;
}

/// Error de la API en formato RFC 9457 (Problem Details), igual que en el frontend web.
class AppException implements Exception {
  const AppException({required this.status, required this.message, this.fieldErrors = const {}});

  const AppException.network()
    : status = 0,
      message = 'No se pudo conectar con el servidor. Revisa tu conexión e inténtalo de nuevo.',
      fieldErrors = const {};

  factory AppException.fromProblem(int status, Map<String, dynamic> body) {
    final errors = body['errors'];
    return AppException(
      status: status,
      message: (body['detail'] ?? body['title'] ?? 'Error inesperado') as String,
      fieldErrors: errors is Map ? errors.map((key, value) => MapEntry('$key', '$value')) : const {},
    );
  }

  final int status;
  final String message;
  final Map<String, String> fieldErrors;

  bool get isUnauthorized => status == 401;

  @override
  String toString() => 'AppException($status): $message';
}
