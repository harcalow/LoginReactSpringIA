import 'package:flutter_test/flutter_test.dart';
import 'package:login_gym/core/network/api_exception.dart';
import 'package:login_gym/features/auth/domain/auth_models.dart';
import 'package:login_gym/features/auth/domain/user.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_app.dart';

void main() {
  late MockAuthApi api;

  setUpAll(() {
    registerFallbackValue(const RegisterData(email: '', firstName: '', lastName: '', password: ''));
  });

  setUp(() => api = MockAuthApi());

  Future<void> fillAll(WidgetTester tester) async {
    await tester.enterText(fieldWithLabel('Correo'), '  Ana@Test.com ');
    await tester.enterText(fieldWithLabel('Nombres'), ' Ana María ');
    await tester.enterText(fieldWithLabel('Apellidos'), 'Pérez');
    await tester.enterText(fieldWithLabel('Contraseña'), 'Secreta123');
    await tester.pumpAndSettle();
  }

  testWidgets('Guardar se habilita solo cuando los 4 campos están completos', (tester) async {
    await pumpAuthApp(tester, api: api, initialLocation: '/register');

    expect(isEnabled(tester, 'Guardar'), isFalse);
    expect(find.text('0 de 4 discos cargados'), findsOneWidget);

    await tester.enterText(fieldWithLabel('Correo'), 'ana@test.com');
    await tester.enterText(fieldWithLabel('Nombres'), 'Ana');
    await tester.enterText(fieldWithLabel('Apellidos'), '   ');
    await tester.pumpAndSettle();
    expect(isEnabled(tester, 'Guardar'), isFalse, reason: 'los espacios no cuentan como contenido');
    expect(find.text('2 de 4 discos cargados'), findsOneWidget);

    await fillAll(tester);
    expect(isEnabled(tester, 'Guardar'), isTrue);
    expect(find.text('Barra cargada. Ya puedes guardar.'), findsOneWidget);
  });

  testWidgets('al guardar envía datos limpios y vuelve al login con el mensaje', (tester) async {
    when(() => api.register(any())).thenAnswer(
      (_) async => const User(id: '1', email: 'ana@test.com', firstName: 'Ana María', lastName: 'Pérez', role: 'USER'),
    );
    await pumpAuthApp(tester, api: api, initialLocation: '/register');

    await fillAll(tester);
    await tester.ensureVisible(buttonWithText('Guardar'));
    await tester.tap(buttonWithText('Guardar'));
    await tester.pumpAndSettle();

    final sent = verify(() => api.register(captureAny())).captured.single as RegisterData;
    expect(sent.email, 'Ana@Test.com');
    expect(sent.firstName, 'Ana María');
    expect(sent.lastName, 'Pérez');
    expect(find.text('¡Cuenta creada! Ya puedes iniciar sesión.'), findsOneWidget);
    expect(find.text('ana@test.com'), findsOneWidget, reason: 'el correo queda precargado en el login');
  });

  testWidgets('muestra el error del backend cuando el correo ya existe', (tester) async {
    when(() => api.register(any())).thenThrow(const ApiException(status: 409, message: 'El correo ya está registrado'));
    await pumpAuthApp(tester, api: api, initialLocation: '/register');

    await fillAll(tester);
    await tester.ensureVisible(buttonWithText('Guardar'));
    await tester.tap(buttonWithText('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('El correo ya está registrado'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget, reason: 'sigue en la pantalla de registro');
  });
}
