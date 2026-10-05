import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static const bodyFont = 'Barlow';
  static const displayFont = 'BigShouldersDisplay';

  /// Titulares con Big Shoulders Display (fuente variable: el peso se fija con `wght`).
  static TextStyle display(double size, {FontWeight weight = FontWeight.w800, Color? color}) => TextStyle(
    fontFamily: displayFont,
    fontSize: size,
    height: 0.95,
    color: color,
    fontWeight: weight,
    fontVariations: [FontVariation.weight(weight.value.toDouble())],
  );

  static ThemeData light() => _build(Brightness.light, AppPalette.light);

  static ThemeData dark() => _build(Brightness.dark, AppPalette.dark);

  static ThemeData _build(Brightness brightness, AppPalette palette) {
    const radius = BorderRadius.all(Radius.circular(6));
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color, width: 2),
    );

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.plateBlue,
      brightness: brightness,
      primary: palette.primary,
      onPrimary: Colors.white,
      error: palette.error,
      surface: palette.surface,
      onSurface: palette.text,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: bodyFont,
      scaffoldBackgroundColor: palette.surface,
      extensions: [palette],
      textTheme: ThemeData(brightness: brightness).textTheme
          .apply(fontFamily: bodyFont, bodyColor: palette.text, displayColor: palette.text),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: border(palette.border),
        enabledBorder: border(palette.border),
        focusedBorder: border(palette.primary),
        errorBorder: border(palette.error),
        focusedErrorBorder: border(palette.error),
        errorStyle: TextStyle(color: palette.error, fontSize: 14),
        helperStyle: TextStyle(color: palette.textMuted, fontSize: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: const RoundedRectangleBorder(borderRadius: radius),
          backgroundColor: palette.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: palette.border,
          disabledForegroundColor: palette.textMuted,
          textStyle: const TextStyle(fontFamily: bodyFont, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: const RoundedRectangleBorder(borderRadius: radius),
          side: BorderSide(color: palette.text, width: 2),
          foregroundColor: palette.text,
          textStyle: const TextStyle(fontFamily: bodyFont, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primary,
          textStyle: const TextStyle(
            fontFamily: bodyFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
