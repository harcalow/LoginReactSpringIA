import 'package:flutter/foundation.dart';

import '../../../domain/models/registration.dart';
import '../../../domain/models/user.dart';
import '../../../utils/result.dart';

/// Fuente única de verdad de la sesión. Notifica a sus oyentes (router, ViewModels) cuando cambia.
abstract class AuthRepository extends ChangeNotifier {
  /// `true` mientras se valida el token guardado al abrir la app.
  bool get isRestoring;

  bool get isAuthenticated => currentUser != null;

  User? get currentUser;

  Future<void> restoreSession();

  Future<Result<User>> login({required String email, required String password});

  /// Crea la cuenta sin iniciar sesión: el usuario ingresa después.
  Future<Result<User>> register(Registration registration);

  Future<void> logout();
}
