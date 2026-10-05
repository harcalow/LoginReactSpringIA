import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Campo con la etiqueta encima del input, igual que el FormField del frontend web.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.onChanged,
    this.errorText,
    this.hint,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.isPassword = false,
    this.maxLength,
    this.onSubmitted,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final String? hint;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final bool isPassword;
  final int? maxLength;
  final ValueChanged<String>? onSubmitted;
  final TextCapitalization textCapitalization;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(fontWeight: FontWeight.w600, color: palette.text, fontSize: 16),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          autofillHints: widget.autofillHints,
          obscureText: widget.isPassword && _obscured,
          enableSuggestions: !widget.isPassword,
          autocorrect: false,
          maxLength: widget.maxLength,
          style: TextStyle(fontSize: 16, color: palette.text),
          decoration: InputDecoration(
            counterText: '',
            errorText: widget.errorText,
            helperText: widget.hint,
            suffixIcon: widget.isPassword
                ? IconButton(
                    tooltip: _obscured ? 'Mostrar contraseña' : 'Ocultar contraseña',
                    icon: Icon(_obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    color: palette.textMuted,
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
