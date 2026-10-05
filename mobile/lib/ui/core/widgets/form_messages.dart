import 'package:flutter/material.dart';

import '../themes/app_colors.dart';

class ErrorMessage extends StatelessWidget {
  const ErrorMessage(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Text(message, style: TextStyle(color: context.palette.error, fontSize: 14)),
    );
  }
}

class SuccessBanner extends StatelessWidget {
  const SuccessBanner(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: palette.successBackground,
          borderRadius: BorderRadius.circular(4),
          border: const Border(left: BorderSide(color: AppColors.plateGreen, width: 4)),
        ),
        child: Text(
          message,
          style: TextStyle(color: palette.successText, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
