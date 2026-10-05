import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';

class _Plate {
  const _Plate(this.color, this.width);

  final Color color;
  final double width;
}

// Discos olímpicos: 25 kg, 20 kg, 15 kg y 10 kg (mismos valores que el SVG del frontend web)
const _plates = [
  _Plate(AppColors.plateRed, 18),
  _Plate(AppColors.plateBlue, 16),
  _Plate(AppColors.plateYellow, 14),
  _Plate(AppColors.plateGreen, 12),
];

const _viewWidth = 400.0;
const _viewHeight = 120.0;
const _gap = 2.0;
const _leftCollar = 116.0;
const _rightCollar = 284.0;
const _slideDistance = 70.0;

/// Barra olímpica que carga un disco por cada campo completado y se levanta al completarse.
class Barbell extends StatelessWidget {
  const Barbell({super.key, required this.loaded, required this.total});

  final int loaded;
  final int total;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final plateDuration = reduceMotion ? Duration.zero : const Duration(milliseconds: 400);
    final liftDuration = reduceMotion ? Duration.zero : const Duration(milliseconds: 600);
    final lifted = loaded >= total;

    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.clamp(0.0, 520.0);
          final s = width / _viewWidth;

          final children = <Widget>[
            _rect(20, 52, 98, 16, AppColors.steel, s),
            _rect(282, 52, 98, 16, AppColors.steel, s),
            _rect(126, 56, 148, 8, AppColors.steelLight, s),
            _rect(118, 42, 8, 36, AppColors.steelLight, s),
            _rect(274, 42, 8, 36, AppColors.steelLight, s),
          ];

          var offset = 0.0;
          for (var i = 0; i < total && i < _plates.length; i++) {
            final plate = _plates[i];
            final isLoaded = i < loaded;
            final left = _leftCollar - offset - plate.width;
            final right = _rightCollar + offset;
            children
              ..add(_plate(plate, isLoaded ? left : left - _slideDistance, isLoaded, s, plateDuration))
              ..add(_plate(plate, isLoaded ? right : right + _slideDistance, isLoaded, s, plateDuration));
            offset += plate.width + _gap;
          }

          return SizedBox(
            width: width,
            child: Column(
              children: [
                AnimatedSlide(
                  offset: Offset(0, lifted ? -22 / _viewHeight : 0),
                  duration: liftDuration,
                  curve: Curves.easeOutBack,
                  child: SizedBox(
                    width: width,
                    height: _viewHeight * s,
                    child: Stack(clipBehavior: Clip.none, children: children),
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedScale(
                  scale: lifted ? 0.8 : 1,
                  duration: liftDuration,
                  curve: Curves.easeOutBack,
                  child: AnimatedOpacity(
                    opacity: lifted ? 0.5 : 1,
                    duration: liftDuration,
                    child: Container(
                      height: 10,
                      margin: EdgeInsets.symmetric(horizontal: width * 0.06),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.elliptical(200, 5)),
                        boxShadow: [BoxShadow(color: Color(0x73000000), blurRadius: 8)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _rect(double x, double y, double w, double h, Color color, double s) => Positioned(
    left: x * s,
    top: y * s,
    width: w * s,
    height: h * s,
    child: DecoratedBox(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2 * s)),
    ),
  );

  Widget _plate(_Plate plate, double x, bool visible, double s, Duration duration) => AnimatedPositioned(
    duration: duration,
    curve: Curves.easeOutBack,
    left: x * s,
    top: 6 * s,
    width: plate.width * s,
    height: 108 * s,
    child: AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: Duration(milliseconds: duration.inMilliseconds * 5 ~/ 8),
      child: DecoratedBox(
        decoration: BoxDecoration(color: plate.color, borderRadius: BorderRadius.circular(3 * s)),
      ),
    ),
  );
}
