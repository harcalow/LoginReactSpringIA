import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:login_gym/core/storage/token_storage.dart';
import 'package:login_gym/core/theme/app_theme.dart';
import 'package:login_gym/features/auth/data/auth_api.dart';
import 'package:login_gym/features/auth/domain/auth_models.dart';
import 'package:login_gym/features/auth/presentation/pages/login_page.dart';
import 'package:login_gym/features/auth/presentation/pages/register_page.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthApi extends Mock implements AuthApi {}

class InMemoryTokenStorage implements TokenStorage {
  String? token;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String value) async => token = value;

  @override
  Future<void> clear() async => token = null;
}

/// Monta las pantallas de autenticación con un router mínimo y la API simulada.
Future<void> pumpAuthApp(WidgetTester tester, {required AuthApi api, required String initialLocation}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('Inicio')),
      ),
      GoRoute(
        path: '/login',
        builder: (_, state) => LoginPage(key: ValueKey(state.extra), notice: state.extra as RegistrationNotice?),
      ),
      GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authApiProvider.overrideWithValue(api),
        tokenStorageProvider.overrideWithValue(InMemoryTokenStorage()),
      ],
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
