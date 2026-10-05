import 'package:flutter/foundation.dart';

import '../../../../data/repositories/auth/auth_repository.dart';
import '../../../../domain/models/user.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required this._authRepository});

  final AuthRepository _authRepository;

  User? get user => _authRepository.currentUser;

  /// El repositorio notifica el cierre de sesión y el router vuelve al login.
  Future<void> logout() => _authRepository.logout();
}
