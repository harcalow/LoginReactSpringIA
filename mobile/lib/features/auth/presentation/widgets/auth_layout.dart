import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import 'barbell.dart';

/// Escenario (titular + barra) y panel con el formulario. Mismo layout que el frontend web:
/// apilado en celular y dividido en dos columnas en pantallas anchas.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.headline,
    required this.tagline,
    required this.filled,
    required this.total,
    required this.readyText,
    required this.child,
  });

  final String title;
  final String headline;
  final String tagline;
  final int filled;
  final int total;
  final String readyText;
  final Widget child;

  static const _wideBreakpoint = 860.0;

  @override
  Widget build(BuildContext context) {
    final loaded = filled.clamp(0, total);
    final isReady = loaded == total;
    final palette = context.palette;

    // Iconos claros en la barra de estado: el escenario superior siempre es oscuro
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: palette.surface,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= _wideBreakpoint;
            final stage = _Stage(
              headline: headline,
              tagline: tagline,
              loaded: loaded,
              total: total,
              progressText: isReady ? readyText : '$loaded de $total discos cargados',
              isReady: isReady,
              isWide: isWide,
            );
            final panel = _Panel(title: title, child: child);

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 11, child: stage),
                  Expanded(flex: 10, child: SingleChildScrollView(child: panel)),
                ],
              );
            }
            return SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [stage, panel]),
            );
          },
        ),
      ),
    );
  }
}

class _Stage extends StatelessWidget {
  const _Stage({
    required this.headline,
    required this.tagline,
    required this.loaded,
    required this.total,
    required this.progressText,
    required this.isReady,
    required this.isWide,
  });

  final String headline;
  final String tagline;
  final int loaded;
  final int total;
  final String progressText;
  final bool isReady;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final headlineSize = isWide ? 88.0 : (width * 0.11).clamp(40.0, 56.0);

    return ColoredBox(
      color: context.palette.stageBackground,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(isWide ? 64 : 16, isWide ? 64 : 32, isWide ? 64 : 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Semantics(
                header: true,
                child: Text(headline, style: AppTheme.display(headlineSize, color: AppColors.chalk)),
              ),
              const SizedBox(height: 16),
              Text(tagline, style: const TextStyle(fontSize: 17, color: AppColors.steelLight)),
              SizedBox(height: isWide ? 56 : 28),
              Barbell(loaded: loaded, total: total),
              const SizedBox(height: 8),
              Text(
                progressText,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: isReady ? AppColors.plateYellow : AppColors.steelLight,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(title, style: AppTheme.display(36, weight: FontWeight.w700)),
                ),
                const SizedBox(height: 28),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
