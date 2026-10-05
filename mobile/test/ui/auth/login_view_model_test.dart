import 'package:flutter_test/flutter_test.dart';
import 'package:login_gym/ui/features/auth/view_models/login_view_model.dart';
import 'package:login_gym/utils/result.dart';

import '../../testing/fakes/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late LoginViewModel viewModel;

  setUp(() {
    repository = FakeAuthRepository();
    viewModel = LoginViewModel(authRepository: repository);
  });

  test('cuenta los campos completos y habilita el envío con ambos', () {
    expect(viewModel.canSubmit, isFalse);
    viewModel.updateEmail('ana@test.com');
    expect(viewModel.filledCount, 1);
    viewModel.updatePassword('   ');
    expect(viewModel.canSubmit, isFalse, reason: 'los espacios no cuentan');
    viewModel.updatePassword('Secreta123');
    expect(viewModel.canSubmit, isTrue);
  });

  test('el correo precargado cuenta como un disco', () {
    expect(LoginViewModel(authRepository: repository, initialEmail: 'ana@test.com').filledCount, 1);
  });

  test('envía el correo sin espacios y no muestra error si el login es exitoso', () async {
    viewModel
      ..updateEmail('  ana@test.com ')
      ..updatePassword('Secreta123');

    await viewModel.login();

    expect(repository.loginCalls.single.email, 'ana@test.com');
    expect(viewModel.errorMessage, isNull);
    expect(viewModel.isSubmitting, isFalse);
  });

  test('expone el mensaje y los errores por campo del backend', () async {
    repository.loginResult = const Result.failure(
      AppException(
        status: 400,
        message: 'Datos de entrada inválidos',
        fieldErrors: {'email': 'El correo no es válido'},
      ),
    );
    viewModel
      ..updateEmail('ana')
      ..updatePassword('Secreta123');

    await viewModel.login();

    expect(viewModel.errorMessage, 'Datos de entrada inválidos');
    expect(viewModel.fieldErrors['email'], 'El correo no es válido');

    viewModel.updateEmail('ana@test.com');
    expect(viewModel.fieldErrors.containsKey('email'), isFalse, reason: 'editar el campo limpia su error');
  });

  test('no llama al repositorio si el formulario está incompleto', () async {
    viewModel.updateEmail('ana@test.com');
    await viewModel.login();
    expect(repository.loginCalls, isEmpty);
  });
}
