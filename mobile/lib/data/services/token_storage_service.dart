import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda el JWT. En Android se cifra con el Keystore del sistema.
abstract interface class TokenStorageService {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> clear();
}

class SecureTokenStorageService implements TokenStorageService {
  SecureTokenStorageService([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'access_token';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String token) => _storage.write(key: _key, value: token);

  @override
  Future<void> clear() => _storage.delete(key: _key);
}
