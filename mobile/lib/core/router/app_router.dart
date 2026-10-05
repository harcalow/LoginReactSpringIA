import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/domain/auth_models.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../theme/app_colors.dart';

const _publicRoutes = {'/login', '/register'};

/// Equivale a AppRouter + ProtectedRoute del frontend web.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref
    ..listen(authControllerProvider, (_, _) => refresh.value++)
    ..onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(authControllerProvider);
      final location = state.matchedLocation;
      if (session.isLoading && !session.hasValue) return location == '/splash' ? null : '/splash';

      final isLoggedIn = session.value != null;
      final isPublic = _publicRoutes.contains(location);
      if (!isLoggedIn) return isPublic ? null : '/login';
      if (isPublic || location == '/splash') return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const _SplashPage()),
      GoRoute(path: '/', builder: (_, _) => const HomePage()),
      GoRoute(
        path: '/login',
        builder: (_, state) => LoginPage(
          // La key cambia con el aviso para reiniciar el formulario al volver del registro
          key: ValueKey(state.extra),
          notice: state.extra as RegistrationNotice?,
        ),
      ),
      GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
    ],
  );
});

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.stageBackground,
      body: const Center(child: CircularProgressIndicator(color: AppColors.plateYellow)),
    );
  }
}
