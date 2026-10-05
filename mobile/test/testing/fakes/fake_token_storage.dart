import 'package:login_gym/data/services/token_storage_service.dart';

class FakeTokenStorage implements TokenStorageService {
  FakeTokenStorage([this.token]);

  String? token;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String value) async => token = value;

  @override
  Future<void> clear() async => token = null;
}
