import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:login_gym/app.dart';

/// Flujo completo contra el backend real (debe estar corriendo en el PC, puerto 8080).
/// Ejecutar con: flutter test integration_test -d emulator-5554
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Finder field(String label) => find.descendant(
    of: find.ancestor(of: find.text(label), matching: find.byType(Column)).first,
    matching: find.byType(TextField),
  );

  Future<void> tapButton(WidgetTester tester, String text) async {
    final button = find.ancestor(of: find.text(text), matching: find.byWidgetPredicate((w) => w is ButtonStyleButton));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 15),
    );
  }

  testWidgets('registro → mensaje → login → bienvenida → cerrar sesión', (tester) async {
    final email = 'e2e.${DateTime.now().millisecondsSinceEpoch}@test.com';

    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();
    expect(find.text('Hoy también se entrena.'), findsOneWidget);

    // Registro
    await tapButton(tester, 'Crear cuenta');
    await tester.enterText(field('Correo'), email);
    await tester.enterText(field('Nombres'), 'Atleta');
    await tester.enterText(field('Apellidos'), 'De Prueba');
    await tester.enterText(field('Contraseña'), 'Secreta123');
    await tester.pumpAndSettle();
    expect(find.text('Barra cargada. Ya puedes guardar.'), findsOneWidget);
    await tapButton(tester, 'Guardar');

    // De vuelta en el login con el mensaje y el correo precargado
    expect(find.text('¡Cuenta creada! Ya puedes iniciar sesión.'), findsOneWidget);
    expect(find.text(email), findsOneWidget);

    // Login
    await tester.enterText(field('Contraseña'), 'Secreta123');
    await tester.pumpAndSettle();
    await tapButton(tester, 'Ingresar');
    expect(find.text('Bienvenido, Atleta.'), findsOneWidget);

    // Cerrar sesión deja el token limpio para la siguiente ejecución
    await tapButton(tester, 'Cerrar sesión');
    expect(find.text('Hoy también se entrena.'), findsOneWidget);
  });
}
