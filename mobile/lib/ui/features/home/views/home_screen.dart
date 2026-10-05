import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_theme.dart';
import '../view_models/home_view_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final user = viewModel.user;

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
                '${user?.fullName ?? ''} (${user?.email ?? ''})',
                style: TextStyle(color: palette.textMuted, fontSize: 16),
              ),
              const SizedBox(height: 24),
              OutlinedButton(onPressed: viewModel.logout, child: const Text('Cerrar sesión')),
            ],
          ),
        ),
      ),
    );
  }
}
