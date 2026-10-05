import 'user.dart';

class RegisterData {
  const RegisterData({required this.email, required this.firstName, required this.lastName, required this.password});

  final String email;
  final String firstName;
  final String lastName;
  final String password;

  Map<String, dynamic> toJson() => {'email': email, 'firstName': firstName, 'lastName': lastName, 'password': password};
}

class AuthResponse {
  const AuthResponse({required this.accessToken, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    accessToken: json['accessToken'] as String,
    user: User.fromJson(json['user'] as Map<String, dynamic>),
  );

  final String accessToken;
  final User user;
}

/// Lo que la pantalla de registro le entrega al login al terminar.
class RegistrationNotice {
  const RegistrationNotice({required this.email, required this.message});

  final String email;
  final String message;
}
