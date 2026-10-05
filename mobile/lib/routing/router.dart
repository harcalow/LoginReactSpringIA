import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/auth/auth_repository.dart';
import '../ui/core/widgets/splash_view.dart';
import '../ui/features/auth/view_models/registration_notice.dart';
import '../ui/features/auth/views/login_screen.dart';
import '../ui/features/auth/views/register_screen.dart';
import '../ui/features/home/view_models/home_view_model.dart';
import '../ui/features/home/views/home_screen.dart';
import 'routes.dart';

const _publicRoutes = {Routes.login, Routes.register};

/// El router escucha al [AuthRepository]: cada cambio de sesión vuelve a evaluar [redirect].
GoRouter router(AuthRepository authRepository) => GoRouter(
  initialLocation: Routes.home,
  refreshListenable: authRepository,
  redirect: (context, state) {
    final location = state.matchedLocation;
    if (authRepository.isRestoring) return location == Routes.splash ? null : Routes.splash;

    final isPublic = _publicRoutes.contains(location);
    if (!authRepository.isAuthenticated) return isPublic ? null : Routes.login;
    if (isPublic || location == Routes.splash) return Routes.home;
    return null;
  },
  routes: [
    GoRoute(path: Routes.splash, builder: (_, _) => const SplashView()),
    GoRoute(
      path: Routes.home,
      builder: (context, _) => HomeScreen(viewModel: HomeViewModel(authRepository: context.read())),
    ),
    GoRoute(
      path: Routes.login,
      // La key cambia con el aviso para reiniciar el formulario al volver del registro
      builder: (_, state) => LoginScreen(key: ValueKey(state.extra), notice: state.extra as RegistrationNotice?),
    ),
    GoRoute(path: Routes.register, builder: (_, _) => const RegisterScreen()),
  ],
);
