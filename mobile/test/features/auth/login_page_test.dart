import 'package:flutter_test/flutter_test.dart';
import 'package:login_gym/core/network/api_exception.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_app.dart';

void main() {
  late MockAuthApi api;

  setUp(() => api = MockAuthApi());

  testWidgets('Ingresar se habilita al completar correo y contraseña', (tester) async {
    await pumpAuthApp(tester, api: api, initialLocation: '/login');

    expect(isEnabled(tester, 'Ingresar'), isFalse);
    await tester.enterText(fieldWithLabel('Correo'), 'prueba@test.com');
    await tester.pumpAndSettle();
    expect(find.text('1 de 2 discos cargados'), findsOneWidget);
    expect(isEnabled(tester, 'Ingresar'), isFalse);

    await tester.enterText(fieldWithLabel('Contraseña'), 'Secreta123');
    await tester.pumpAndSettle();
    expect(isEnabled(tester, 'Ingresar'), isTrue);
    expect(find.text('Barra cargada. Ya puedes ingresar.'), findsOneWidget);
  });

  testWidgets('muestra "Credenciales inválidas" cuando el backend rechaza el login', (tester) async {
    when(
      () => api.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(const ApiException(status: 401, message: 'Credenciales inválidas'));
    await pumpAuthApp(tester, api: api, initialLocation: '/login');

    await tester.enterText(fieldWithLabel('Correo'), 'prueba@test.com');
    await tester.enterText(fieldWithLabel('Contraseña'), 'mala');
    await tester.pumpAndSettle();
    await tester.ensureVisible(buttonWithText('Ingresar'));
    await tester.tap(buttonWithText('Ingresar'));
    await tester.pumpAndSettle();

    expect(find.text('Credenciales inválidas'), findsOneWidget);
  });

  testWidgets('"Crear cuenta" abre el registro', (tester) async {
    await pumpAuthApp(tester, api: api, initialLocation: '/login');

    await tester.ensureVisible(buttonWithText('Crear cuenta'));
    await tester.tap(buttonWithText('Crear cuenta'));
    await tester.pumpAndSettle();

    expect(find.text('Tu primera serie empieza aquí.'), findsOneWidget);
  });
}
