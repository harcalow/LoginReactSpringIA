/// Error de la API en formato RFC 9457 (Problem Details), igual que en el frontend web.
class ApiException implements Exception {
  const ApiException({required this.status, required this.message, this.fieldErrors = const {}});

  const ApiException.network()
    : status = 0,
      message = 'No se pudo conectar con el servidor. Revisa tu conexión e inténtalo de nuevo.',
      fieldErrors = const {};

  factory ApiException.fromProblem(int status, Map<String, dynamic> body) {
    final errors = body['errors'];
    return ApiException(
      status: status,
      message: (body['detail'] ?? body['title'] ?? 'Error inesperado') as String,
      fieldErrors: errors is Map ? errors.map((key, value) => MapEntry('$key', '$value')) : const {},
    );
  }

  final int status;
  final String message;
  final Map<String, String> fieldErrors;

  @override
  String toString() => 'ApiException($status): $message';
}
