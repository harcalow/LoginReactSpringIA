import 'package:login_gym/data/repositories/auth/auth_repository.dart';
import 'package:login_gym/domain/models/registration.dart';
import 'package:login_gym/domain/models/user.dart';
import 'package:login_gym/utils/result.dart';

const testUser = User(id: '1', email: 'ana@test.com', firstName: 'Ana María', lastName: 'Pérez', role: 'USER');

class FakeAuthRepository extends AuthRepository {
  Result<User> loginResult = const Result.ok(testUser);
  Result<User> registerResult = const Result.ok(testUser);
  final loginCalls = <({String email, String password})>[];
  final registerCalls = <Registration>[];
  User? _user;

  @override
  bool get isRestoring => false;

  @override
  User? get currentUser => _user;

  @override
  Future<void> restoreSession() async {}

  @override
  Future<Result<User>> login({required String email, required String password}) async {
    loginCalls.add((email: email, password: password));
    if (loginResult case Ok(:final value)) {
      _user = value;
      notifyListeners();
    }
    return loginResult;
  }

  @override
  Future<Result<User>> register(Registration registration) async {
    registerCalls.add(registration);
    return registerResult;
  }

  @override
  Future<void> logout() async {
    _user = null;
    notifyListeners();
  }
}
