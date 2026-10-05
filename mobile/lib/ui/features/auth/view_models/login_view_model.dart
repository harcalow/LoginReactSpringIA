import 'package:flutter/foundation.dart';

import '../../../../data/repositories/auth/auth_repository.dart';
import '../../../../utils/result.dart';
import 'count_filled.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required this._authRepository, String initialEmail = ''}) : _email = initialEmail;

  static const totalFields = 2;

  final AuthRepository _authRepository;

  String _email;
  String _password = '';
  bool _isSubmitting = false;
  String? _errorMessage;
  Map<String, String> _fieldErrors = const {};
  bool _disposed = false;

  String get email => _email;
  int get filledCount => countFilled([_email, _password]);
  bool get isComplete => filledCount == totalFields;
  bool get canSubmit => isComplete && !_isSubmitting;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  Map<String, String> get fieldErrors => _fieldErrors;

  void updateEmail(String value) => _update(() => _email = value, 'email');

  void updatePassword(String value) => _update(() => _password = value, 'password');

  /// Si el login es exitoso, el repositorio notifica la nueva sesión y el router redirige.
  Future<void> login() async {
    if (!canSubmit) return;
    _isSubmitting = true;
    _errorMessage = null;
    _fieldErrors = const {};
    _notify();

    final result = await _authRepository.login(email: _email.trim(), password: _password);
    if (result case Failure(:final error)) {
      _errorMessage = error.message;
      _fieldErrors = Map.unmodifiable(error.fieldErrors);
    }
    _isSubmitting = false;
    _notify();
  }

  void _update(void Function() change, String field) {
    change();
    if (_fieldErrors.containsKey(field)) _fieldErrors = Map.unmodifiable(Map.of(_fieldErrors)..remove(field));
    _notify();
  }

  // El login exitoso cierra esta pantalla antes de que termine el comando
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
