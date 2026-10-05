import 'package:flutter/material.dart';

import '../themes/app_colors.dart';

/// Se muestra mientras el repositorio valida el token guardado.
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.stageBackground,
      body: const Center(child: CircularProgressIndicator(color: AppColors.plateYellow)),
    );
  }
}
