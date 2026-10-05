import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../utils/result.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
import '../models/user_api_model.dart';

/// Service sin estado que envuelve la API REST del backend. Devuelve modelos de API en un [Result].
class ApiClient {
  ApiClient({required this._baseUrl, required this._tokenProvider, http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  static const _timeout = Duration(seconds: 15);

  final String _baseUrl;
  final Future<String?> Function() _tokenProvider;
  final http.Client _http;

  Future<Result<LoginResponse>> login(LoginRequest request) =>
      _send('POST', '/api/auth/login', request.toJson(), LoginResponse.fromJson);

  Future<Result<UserApiModel>> register(RegisterRequest request) =>
      _send('POST', '/api/auth/register', request.toJson(), UserApiModel.fromJson);

  Future<Result<UserApiModel>> getCurrentUser() => _send('GET', '/api/users/me', null, UserApiModel.fromJson);

  Future<Result<T>> _send<T>(
    String method,
    String path,
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>) parse,
  ) async {
    final request = http.Request(method, Uri.parse('$_baseUrl$path'))..headers['Accept'] = 'application/json';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json; charset=utf-8';
      request.body = jsonEncode(body);
    }
    final token = await _tokenProvider();
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    final http.Response response;
    try {
      response = await http.Response.fromStream(await _http.send(request).timeout(_timeout));
    } on Exception {
      return const Result.failure(AppException.network());
    }

    final json = _decode(response);
    if (response.statusCode >= 400) return Result.failure(AppException.fromProblem(response.statusCode, json));
    try {
      return Result.ok(parse(json));
    } on Object {
      return const Result.failure(AppException(status: 0, message: 'Respuesta inesperada del servidor'));
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.bodyBytes.isEmpty) return const {};
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return decoded is Map<String, dynamic> ? decoded : const {};
    } on FormatException {
      return const {};
    }
  }
}
