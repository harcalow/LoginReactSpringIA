import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_api_model.dart';

part 'login_response.freezed.dart';
part 'login_response.g.dart';

/// Respuesta de `POST /api/auth/login`.
@freezed
abstract class LoginResponse with _$LoginResponse {
  const factory LoginResponse({required String accessToken, required UserApiModel user}) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
}
