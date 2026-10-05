import 'package:freezed_annotation/freezed_annotation.dart';

part 'registration.freezed.dart';

/// Datos que el usuario ingresa para crear su cuenta.
@freezed
abstract class Registration with _$Registration {
  const factory Registration({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  }) = _Registration;
}
