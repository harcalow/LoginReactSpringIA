import '../../../domain/models/registration.dart';
import '../../../domain/models/user.dart';
import '../../../utils/result.dart';
import '../../models/login_request.dart';
import '../../models/register_request.dart';
import '../../models/user_api_model.dart';
import '../../services/api_client.dart';
import '../../services/token_storage_service.dart';
import 'auth_repository.dart';

class AuthRepositoryRemote extends AuthRepository {
  AuthRepositoryRemote({required this._apiClient, required this._tokenStorage});

  final ApiClient _apiClient;
  final TokenStorageService _tokenStorage;

  bool _isRestoring = true;
  User? _currentUser;

  @override
  bool get isRestoring => _isRestoring;

  @override
  User? get currentUser => _currentUser;

  @override
  Future<void> restoreSession() async {
    if (await _tokenStorage.read() != null) {
      switch (await _apiClient.getCurrentUser()) {
        case Ok(:final value):
          _currentUser = _toDomain(value);
        case Failure(:final error):
          // Token vencido o inválido: se descarta. Un error de red conserva el token para reintentar.
          if (error.isUnauthorized) await _tokenStorage.clear();
      }
    }
    _isRestoring = false;
    notifyListeners();
  }

  @override
  Future<Result<User>> login({required String email, required String password}) async {
    final result = await _apiClient.login(LoginRequest(email: email, password: password));
    switch (result) {
      case Ok(:final value):
        await _tokenStorage.write(value.accessToken);
        _currentUser = _toDomain(value.user);
        notifyListeners();
        return Result.ok(_currentUser!);
      case Failure(:final error):
        return Result.failure(error);
    }
  }

  @override
  Future<Result<User>> register(Registration registration) async {
    final result = await _apiClient.register(
      RegisterRequest(
        email: registration.email,
        firstName: registration.firstName,
        lastName: registration.lastName,
        password: registration.password,
      ),
    );
    return switch (result) {
      Ok(:final value) => Result.ok(_toDomain(value)),
      Failure(:final error) => Result.failure(error),
    };
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.clear();
    _currentUser = null;
    notifyListeners();
  }

  User _toDomain(UserApiModel model) =>
      User(id: model.id, email: model.email, firstName: model.firstName, lastName: model.lastName, role: model.role);
}
