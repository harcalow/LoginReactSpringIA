import 'package:flutter_test/flutter_test.dart';
import 'package:login_gym/routing/routes.dart';
import 'package:login_gym/utils/result.dart';

import '../../testing/fakes/fake_auth_repository.dart';
import '../../testing/screen_harness.dart';

void main() {
  late FakeAuthRepository repository;

  setUp(() => repository = FakeAuthRepository());

  testWidgets('login: Ingresar se habilita al completar y la barra muestra el progreso', (tester) async {
    await pumpAuthScreens(tester, repository: repository, location: Routes.login);

    expect(isEnabled(tester, 'Ingresar'), isFalse);
    await tester.enterText(fieldWithLabel('Correo'), 'prueba@test.com');
    await tester.pumpAndSettle();
    expect(find.text('1 de 2 discos cargados'), findsOneWidget);

    await tester.enterText(fieldWithLabel('Contraseña'), 'Secreta123');
    await tester.pumpAndSettle();
    expect(isEnabled(tester, 'Ingresar'), isTrue);
    expect(find.text('Barra cargada. Ya puedes ingresar.'), findsOneWidget);
  });

  testWidgets('login: muestra "Credenciales inválidas"', (tester) async {
    repository.loginResult = const Result.failure(AppException(status: 401, message: 'Credenciales inválidas'));
    await pumpAuthScreens(tester, repository: repository, location: Routes.login);

    await tester.enterText(fieldWithLabel('Correo'), 'prueba@test.com');
    await tester.enterText(fieldWithLabel('Contraseña'), 'mala');
    await tester.pumpAndSettle();
    await tapButton(tester, 'Ingresar');

    expect(find.text('Credenciales inválidas'), findsOneWidget);
  });

  testWidgets('registro completo vuelve al login con el mensaje y el correo precargado', (tester) async {
    await pumpAuthScreens(tester, repository: repository, location: Routes.login);
    await tapButton(tester, 'Crear cuenta');
    expect(find.text('Tu primera serie empieza aquí.'), findsOneWidget);
    expect(isEnabled(tester, 'Guardar'), isFalse);

    await tester.enterText(fieldWithLabel('Correo'), 'ana@test.com');
    await tester.enterText(fieldWithLabel('Nombres'), 'Ana María');
    await tester.enterText(fieldWithLabel('Apellidos'), 'Pérez');
    await tester.enterText(fieldWithLabel('Contraseña'), 'Secreta123');
    await tester.pumpAndSettle();
    expect(find.text('Barra cargada. Ya puedes guardar.'), findsOneWidget);
    await tapButton(tester, 'Guardar');

    expect(find.text('¡Cuenta creada! Ya puedes iniciar sesión.'), findsOneWidget);
    expect(find.text('ana@test.com'), findsOneWidget);
  });

  testWidgets('registro: muestra el error cuando el correo ya existe', (tester) async {
    repository.registerResult = const Result.failure(
      AppException(status: 409, message: 'El correo ya está registrado'),
    );
    await pumpAuthScreens(tester, repository: repository, location: Routes.register);

    await tester.enterText(fieldWithLabel('Correo'), 'ana@test.com');
    await tester.enterText(fieldWithLabel('Nombres'), 'Ana');
    await tester.enterText(fieldWithLabel('Apellidos'), 'Pérez');
    await tester.enterText(fieldWithLabel('Contraseña'), 'Secreta123');
    await tester.pumpAndSettle();
    await tapButton(tester, 'Guardar');

    expect(find.text('El correo ya está registrado'), findsOneWidget);
  });
}
