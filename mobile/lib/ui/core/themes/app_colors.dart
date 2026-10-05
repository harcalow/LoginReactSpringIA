import 'package:flutter/material.dart';

/// Mismos tokens que el frontend web (frontend/src/index.css).
abstract final class AppColors {
  static const chalk = Color(0xFFE9ECE9);
  static const chalkStrong = Color(0xFFF6F7F6);
  static const iron = Color(0xFF1C2430);
  static const ironSoft = Color(0xFF4A5566);
  static const steel = Color(0xFF8A97A6);
  static const steelLight = Color(0xFFC3CCD6);

  // Colores reglamentarios de discos olímpicos
  static const plateRed = Color(0xFFD62839);
  static const plateBlue = Color(0xFF1F5FBF);
  static const plateYellow = Color(0xFFF2B705);
  static const plateGreen = Color(0xFF2E9E5B);
}

/// Colores que cambian entre modo claro y oscuro.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.text,
    required this.textMuted,
    required this.border,
    required this.primary,
    required this.error,
    required this.successBackground,
    required this.successText,
    required this.stageBackground,
  });

  static const light = AppPalette(
    background: AppColors.chalk,
    surface: AppColors.chalkStrong,
    text: AppColors.iron,
    textMuted: AppColors.ironSoft,
    border: Color(0xFFB9C1CB),
    primary: AppColors.plateBlue,
    error: Color(0xFFB3261E),
    successBackground: Color(0xFFDCEFE3),
    successText: Color(0xFF1E6B3E),
    stageBackground: AppColors.iron,
  );

  static const dark = AppPalette(
    background: Color(0xFF141B24),
    surface: Color(0xFF1A222D),
    text: AppColors.chalk,
    textMuted: Color(0xFFA7B1BD),
    border: Color(0xFF3A4655),
    primary: Color(0xFF3D7DDB),
    error: Color(0xFFFF8A80),
    successBackground: Color(0xFF183626),
    successText: Color(0xFF8FD6AB),
    stageBackground: Color(0xFF0F151D),
  );

  final Color background;
  final Color surface;
  final Color text;
  final Color textMuted;
  final Color border;
  final Color primary;
  final Color error;
  final Color successBackground;
  final Color successText;
  final Color stageBackground;

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(AppPalette? other, double t) => t < 0.5 || other == null ? this : other;
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
