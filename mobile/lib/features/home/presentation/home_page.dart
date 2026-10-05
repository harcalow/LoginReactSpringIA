import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/application/auth_controller.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Bienvenido, ${user?.firstName ?? ''}.', style: AppTheme.display(48)),
              const SizedBox(height: 12),
              Text(
                '${user?.firstName ?? ''} ${user?.lastName ?? ''} (${user?.email ?? ''})',
                style: TextStyle(color: palette.textMuted, fontSize: 16),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
