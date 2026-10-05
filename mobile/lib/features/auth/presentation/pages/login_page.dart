import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/form_messages.dart';
import '../../application/auth_controller.dart';
import '../../domain/auth_models.dart';
import '../widgets/auth_layout.dart';
import '../widgets/count_filled.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.notice});

  /// Mensaje y correo que llegan desde el registro.
  final RegistrationNotice? notice;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late final _email = TextEditingController(text: widget.notice?.email ?? '');
  final _password = TextEditingController();
  late int _filled = countFilled([_email, _password]);
  String? _error;
  Map<String, String> _fieldErrors = const {};
  bool _isSubmitting = false;

  bool get _isComplete => _filled == 2;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _onChanged(String field) {
    setState(() {
      _filled = countFilled([_email, _password]);
      _fieldErrors = Map.of(_fieldErrors)..remove(field);
    });
  }

  Future<void> _submit() async {
    if (!_isComplete || _isSubmitting) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      _fieldErrors = const {};
      _isSubmitting = true;
    });
    try {
      await ref.read(authControllerProvider.notifier).login(email: _email.text.trim(), password: _password.text);
      // La redirección a "/" la hace el router al cambiar la sesión
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _fieldErrors = e.fieldErrors;
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final notice = widget.notice;

    return AuthLayout(
      title: 'Iniciar sesión',
      headline: 'Hoy también se entrena.',
      tagline: 'Inicia sesión para seguir con tu plan.',
      filled: _filled,
      total: 2,
      readyText: 'Barra cargada. Ya puedes ingresar.',
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (notice != null) ...[SuccessBanner(notice.message), const SizedBox(height: 24)],
            AppTextField(
              label: 'Correo',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              errorText: _fieldErrors['email'],
              onChanged: (_) => _onChanged('email'),
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Contraseña',
              controller: _password,
              isPassword: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              errorText: _fieldErrors['password'],
              onChanged: (_) => _onChanged('password'),
              onSubmitted: (_) => _submit(),
            ),
            if (_error != null) ...[const SizedBox(height: 16), ErrorMessage(_error!)],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _isComplete && !_isSubmitting ? _submit : null,
              child: Text(_isSubmitting ? 'Ingresando…' : 'Ingresar'),
            ),
            const SizedBox(height: 32),
            Divider(color: palette.border, height: 1),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                Text('¿Aún no tienes cuenta?', style: TextStyle(color: palette.textMuted, fontSize: 16)),
                OutlinedButton(onPressed: () => context.push('/register'), child: const Text('Crear cuenta')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
