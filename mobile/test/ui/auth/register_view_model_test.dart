import 'package:flutter_test/flutter_test.dart';
import 'package:login_gym/ui/features/auth/view_models/register_view_model.dart';
import 'package:login_gym/utils/result.dart';

import '../../testing/fakes/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late RegisterViewModel viewModel;

  void fillAll() => viewModel
    ..updateEmail('  Ana@Test.com ')
    ..updateFirstName(' Ana María ')
    ..updateLastName('Pérez')
    ..updatePassword('Secreta123');

  setUp(() {
    repository = FakeAuthRepository();
    viewModel = RegisterViewModel(authRepository: repository);
  });

  test('Guardar se habilita solo con los 4 campos completos', () {
    viewModel
      ..updateEmail('ana@test.com')
      ..updateFirstName('Ana')
      ..updateLastName('  ');
    expect(viewModel.filledCount, 2);
    expect(viewModel.canSubmit, isFalse);

    fillAll();
    expect(viewModel.canSubmit, isTrue);
  });

  test('envía los datos sin espacios y devuelve el usuario creado', () async {
    fillAll();

    final user = await viewModel.register();

    expect(user, testUser);
    final sent = repository.registerCalls.single;
    expect(sent.email, 'Ana@Test.com');
    expect(sent.firstName, 'Ana María');
    expect(sent.password, 'Secreta123');
  });

  test('si el correo existe devuelve null y expone el error', () async {
    repository.registerResult = const Result.failure(
      AppException(status: 409, message: 'El correo ya está registrado'),
    );
    fillAll();

    expect(await viewModel.register(), isNull);
    expect(viewModel.errorMessage, 'El correo ya está registrado');
    expect(viewModel.isSubmitting, isFalse);
  });
}
