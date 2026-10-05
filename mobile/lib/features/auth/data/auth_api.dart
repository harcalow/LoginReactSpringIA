import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/auth_models.dart';
import '../domain/user.dart';

class AuthApi {
  const AuthApi(this._client);

  final ApiClient _client;

  Future<AuthResponse> login({required String email, required String password}) async =>
      AuthResponse.fromJson(await _client.post('/api/auth/login', {'email': email, 'password': password}));

  Future<User> register(RegisterData data) async =>
      User.fromJson(await _client.post('/api/auth/register', data.toJson()));

  Future<User> me() async => User.fromJson(await _client.get('/api/users/me'));
}

final authApiProvider = Provider<AuthApi>((ref) => AuthApi(ref.watch(apiClientProvider)));
