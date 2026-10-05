import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_api_model.freezed.dart';
part 'user_api_model.g.dart';

/// Respuesta de `GET /api/users/me` y `POST /api/auth/register`.
@freezed
abstract class UserApiModel with _$UserApiModel {
  const factory UserApiModel({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    required String role,
  }) = _UserApiModel;

  factory UserApiModel.fromJson(Map<String, dynamic> json) => _$UserApiModelFromJson(json);
}
