import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../config/env.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({required this._baseUrl, required this._tokenStorage, http.Client? httpClient, this.onUnauthorized})
    : _http = httpClient ?? http.Client();

  static const _timeout = Duration(seconds: 15);

  final String _baseUrl;
  final TokenStorage _tokenStorage;
  final http.Client _http;

  /// Se invoca cuando el backend rechaza el token (401).
  final void Function()? onUnauthorized;

  Future<Map<String, dynamic>> get(String path) => _send('GET', path);

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) => _send('POST', path, body);

  Future<Map<String, dynamic>> _send(String method, String path, [Map<String, dynamic>? body]) async {
    final token = await _tokenStorage.read();
    final request = http.Request(method, Uri.parse('$_baseUrl$path'))..headers['Accept'] = 'application/json';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json; charset=utf-8';
      request.body = jsonEncode(body);
    }
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    final http.Response response;
    try {
      response = await http.Response.fromStream(await _http.send(request).timeout(_timeout));
    } on Exception {
      throw const ApiException.network();
    }

    final json = _decode(response);
    if (response.statusCode == 401 && token != null) {
      await _tokenStorage.clear();
      onUnauthorized?.call();
    }
    if (response.statusCode >= 400) throw ApiException.fromProblem(response.statusCode, json);
    return json;
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

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    baseUrl: Env.apiUrl,
    tokenStorage: ref.watch(tokenStorageProvider),
    // Se resuelve en diferido para evitar una dependencia circular con el controlador de sesión
    onUnauthorized: () => ref.read(sessionExpiredProvider.notifier).notify(),
  );
});

/// Señal de "sesión expirada" que escucha el controlador de autenticación.
class SessionExpiredNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void notify() => state++;
}

final sessionExpiredProvider = NotifierProvider<SessionExpiredNotifier, int>(SessionExpiredNotifier.new);
