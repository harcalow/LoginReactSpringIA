import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_api.dart';
import '../domain/user.dart';

/// Sesión actual: `null` = sin sesión. Equivale al AuthProvider del frontend web.
class AuthController extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    // El ApiClient avisa cuando el backend responde 401
    ref.listen(sessionExpiredProvider, (_, _) {
      if (state.value != null) state = const AsyncData(null);
    });

    // Restaura la sesión si hay un token guardado
    if (await ref.read(tokenStorageProvider).read() == null) return null;
    try {
      return await ref.read(authApiProvider).me();
    } on ApiException {
      return null;
    }
  }

  /// Lanza [ApiException] si las credenciales no son válidas; el formulario la muestra.
  Future<void> login({required String email, required String password}) async {
    final response = await ref.read(authApiProvider).login(email: email, password: password);
    await ref.read(tokenStorageProvider).write(response.accessToken);
    state = AsyncData(response.user);
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clear();
    state = const AsyncData(null);
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(AuthController.new);
