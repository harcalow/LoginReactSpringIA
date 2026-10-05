import 'package:flutter_test/flutter_test.dart';
import 'package:login_gym/data/models/login_request.dart';
import 'package:login_gym/data/models/login_response.dart';
import 'package:login_gym/data/models/register_request.dart';
import 'package:login_gym/data/models/user_api_model.dart';
import 'package:login_gym/data/repositories/auth/auth_repository_remote.dart';
import 'package:login_gym/data/services/api_client.dart';
import 'package:login_gym/domain/models/registration.dart';
import 'package:login_gym/utils/result.dart';
import 'package:mocktail/mocktail.dart';

import '../../testing/fakes/fake_token_storage.dart';

class MockApiClient extends Mock implements ApiClient {}

const _apiUser = UserApiModel(id: '1', email: 'ana@test.com', firstName: 'Ana', lastName: 'Pérez', role: 'USER');

void main() {
  late MockApiClient api;
  late FakeTokenStorage storage;
  late AuthRepositoryRemote repository;
  late int notifications;

  setUpAll(() {
    registerFallbackValue(const LoginRequest(email: '', password: ''));
    registerFallbackValue(const RegisterRequest(email: '', firstName: '', lastName: '', password: ''));
  });

  setUp(() {
    api = MockApiClient();
    storage = FakeTokenStorage();
    repository = AuthRepositoryRemote(apiClient: api, tokenStorage: storage);
    notifications = 0;
    repository.addListener(() => notifications++);
  });

  group('restoreSession', () {
    test('sin token termina sin sesión y sin llamar a la API', () async {
      await repository.restoreSession();

      expect(repository.isRestoring, isFalse);
      expect(repository.isAuthenticated, isFalse);
      verifyNever(() => api.getCurrentUser());
      expect(notifications, 1);
    });

    test('con token válido recupera el usuario', () async {
      storage.token = 'jwt';
      when(() => api.getCurrentUser()).thenAnswer((_) async => const Result.ok(_apiUser));

      await repository.restoreSession();

      expect(repository.currentUser?.email, 'ana@test.com');
    });

    test('con token vencido (401) lo descarta', () async {
      storage.token = 'vencido';
      when(() => api.getCurrentUser())
          .thenAnswer((_) async => const Result.failure(AppException(status: 401, message: 'No autorizado')));

      await repository.restoreSession();

      expect(repository.isAuthenticated, isFalse);
      expect(storage.token, isNull);
    });

    test('con error de red conserva el token para reintentar', () async {
      storage.token = 'jwt';
      when(() => api.getCurrentUser()).thenAnswer((_) async => const Result.failure(AppException.network()));

      await repository.restoreSession();

      expect(repository.isAuthenticated, isFalse);
      expect(storage.token, 'jwt');
    });
  });

  test('login exitoso guarda el token, expone el usuario de dominio y notifica', () async {
    when(() => api.login(any()))
        .thenAnswer((_) async => const Result.ok(LoginResponse(accessToken: 'jwt', user: _apiUser)));

    final result = await repository.login(email: 'ana@test.com', password: 'Secreta123');

    expect(result, isA<Ok>());
    expect(storage.token, 'jwt');
    expect(repository.currentUser?.fullName, 'Ana Pérez');
    expect(notifications, 1);
  });

  test('login fallido no guarda token ni notifica', () async {
    when(() => api.login(any()))
        .thenAnswer((_) async => const Result.failure(AppException(status: 401, message: 'Credenciales inválidas')));

    final result = await repository.login(email: 'ana@test.com', password: 'mala');

    expect((result as Failure).error.message, 'Credenciales inválidas');
    expect(storage.token, isNull);
    expect(notifications, 0);
  });

  test('register crea la cuenta sin iniciar sesión', () async {
    when(() => api.register(any())).thenAnswer((_) async => const Result.ok(_apiUser));

    final result = await repository.register(
      const Registration(email: 'ana@test.com', firstName: 'Ana', lastName: 'Pérez', password: 'Secreta123'),
    );

    expect(result, isA<Ok>());
    expect(repository.isAuthenticated, isFalse);
    final sent = verify(() => api.register(captureAny())).captured.single as RegisterRequest;
    expect(sent.firstName, 'Ana');
  });

  test('logout borra el token y la sesión', () async {
    storage.token = 'jwt';
    await repository.logout();

    expect(storage.token, isNull);
    expect(repository.isAuthenticated, isFalse);
    expect(notifications, 1);
  });
}
