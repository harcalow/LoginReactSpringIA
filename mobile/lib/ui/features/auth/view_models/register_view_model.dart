import 'package:flutter/foundation.dart';

import '../../../../data/repositories/auth/auth_repository.dart';
import '../../../../domain/models/registration.dart';
import '../../../../domain/models/user.dart';
import '../../../../utils/result.dart';
import 'count_filled.dart';

class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel({required this._authRepository});

  static const totalFields = 4;

  final AuthRepository _authRepository;

  String _email = '';
  String _firstName = '';
  String _lastName = '';
  String _password = '';
  bool _isSubmitting = false;
  String? _errorMessage;
  Map<String, String> _fieldErrors = const {};
  bool _disposed = false;

  int get filledCount => countFilled([_email, _firstName, _lastName, _password]);

  /// "Guardar" solo se habilita cuando todos los campos obligatorios tienen contenido.
  bool get isComplete => filledCount == totalFields;
  bool get canSubmit => isComplete && !_isSubmitting;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  Map<String, String> get fieldErrors => _fieldErrors;

  void updateEmail(String value) => _update(() => _email = value, 'email');

  void updateFirstName(String value) => _update(() => _firstName = value, 'firstName');

  void updateLastName(String value) => _update(() => _lastName = value, 'lastName');

  void updatePassword(String value) => _update(() => _password = value, 'password');

  /// Devuelve el usuario creado, o `null` si falló (el error queda en [errorMessage]).
  Future<User?> register() async {
    if (!canSubmit) return null;
    _isSubmitting = true;
    _errorMessage = null;
    _fieldErrors = const {};
    _notify();

    final result = await _authRepository.register(
      Registration(email: _email.trim(), firstName: _firstName.trim(), lastName: _lastName.trim(), password: _password),
    );
    _isSubmitting = false;
    switch (result) {
      case Ok(:final value):
        _notify();
        return value;
      case Failure(:final error):
        _errorMessage = error.message;
        _fieldErrors = Map.unmodifiable(error.fieldErrors);
        _notify();
        return null;
    }
  }

  void _update(void Function() change, String field) {
    change();
    if (_fieldErrors.containsKey(field)) _fieldErrors = Map.unmodifiable(Map.of(_fieldErrors)..remove(field));
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
