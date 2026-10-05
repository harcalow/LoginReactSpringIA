import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:login_gym/config/dependencies.dart';
import 'package:login_gym/main.dart';
import 'package:provider/provider.dart';

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

  /// Las peticiones HTTP reales no programan frames: se espera hasta ver el resultado.
  Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final end = DateTime.now().add(timeout);
    while (finder.evaluate().isEmpty) {
      if (DateTime.now().isAfter(end)) {
        final texts = find.byType(Text).evaluate().map((e) => (e.widget as Text).data).whereType<String>();
        fail('No apareció $finder. Textos en pantalla: ${texts.join(' | ')}');
      }
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
  }

  testWidgets('registro → mensaje → login → bienvenida → cerrar sesión', (tester) async {
    final email = 'e2e.${DateTime.now().millisecondsSinceEpoch}@test.com';

    await tester.pumpWidget(MultiProvider(providers: providers, child: const App()));
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 20),
    );
    await pumpUntilFound(tester, find.text('Hoy también se entrena.'));

    await tapButton(tester, 'Crear cuenta');
    await tester.enterText(field('Correo'), email);
    await tester.enterText(field('Nombres'), 'Atleta');
    await tester.enterText(field('Apellidos'), 'De Prueba');
    await tester.enterText(field('Contraseña'), 'Secreta123');
    await tester.pumpAndSettle();
    expect(find.text('Barra cargada. Ya puedes guardar.'), findsOneWidget);
    await tapButton(tester, 'Guardar');

    await pumpUntilFound(tester, find.text('¡Cuenta creada! Ya puedes iniciar sesión.'));
    expect(find.text(email), findsOneWidget);

    await tester.enterText(field('Contraseña'), 'Secreta123');
    await tester.pumpAndSettle();
    await tapButton(tester, 'Ingresar');
    await pumpUntilFound(tester, find.text('Bienvenido, Atleta.'));

    await tapButton(tester, 'Cerrar sesión');
    await pumpUntilFound(tester, find.text('Hoy también se entrena.'));
  });
}
