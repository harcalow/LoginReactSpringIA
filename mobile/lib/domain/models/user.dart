import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

/// Usuario autenticado, tal como lo usa la UI.
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    required String role,
  }) = _User;

  const User._();

  String get fullName => '$firstName $lastName';
}
