import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:login_gym/data/repositories/auth/auth_repository.dart';
import 'package:login_gym/routing/routes.dart';
import 'package:login_gym/ui/core/themes/app_theme.dart';
import 'package:login_gym/ui/features/auth/view_models/registration_notice.dart';
import 'package:login_gym/ui/features/auth/views/login_screen.dart';
import 'package:login_gym/ui/features/auth/views/register_screen.dart';
import 'package:provider/provider.dart';

/// Monta las pantallas de autenticación con un router mínimo y un repositorio falso.
Future<void> pumpAuthScreens(
  WidgetTester tester, {
  required AuthRepository repository,
  required String location,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    initialLocation: location,
    routes: [
      GoRoute(
        path: Routes.home,
        builder: (_, _) => const Scaffold(body: Text('Inicio')),
      ),
      GoRoute(
        path: Routes.login,
        builder: (_, state) => LoginScreen(key: ValueKey(state.extra), notice: state.extra as RegistrationNotice?),
      ),
      GoRoute(path: Routes.register, builder: (_, _) => const RegisterScreen()),
    ],
  );

  await tester.pumpWidget(
    ChangeNotifierProvider<AuthRepository>.value(
      value: repository,
      child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

Finder buttonWithText(String text) =>
    find.ancestor(of: find.text(text), matching: find.byWidgetPredicate((w) => w is ButtonStyleButton));

bool isEnabled(WidgetTester tester, String text) => tester.widget<ButtonStyleButton>(buttonWithText(text)).enabled;

Finder fieldWithLabel(String label) => find.descendant(
  of: find.ancestor(of: find.text(label), matching: find.byType(Column)).first,
  matching: find.byType(TextField),
);

Future<void> tapButton(WidgetTester tester, String text) async {
  await tester.ensureVisible(buttonWithText(text));
  await tester.tap(buttonWithText(text));
  await tester.pumpAndSettle();
}
