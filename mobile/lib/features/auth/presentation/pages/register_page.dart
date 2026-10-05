import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/form_messages.dart';
import '../../data/auth_api.dart';
import '../../domain/auth_models.dart';
import '../widgets/auth_layout.dart';
import '../widgets/count_filled.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _email = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _password = TextEditingController();
  late final _fields = [_email, _firstName, _lastName, _password];
  int _filled = 0;
  String? _error;
  Map<String, String> _fieldErrors = const {};
  bool _isSubmitting = false;

  // "Guardar" solo se habilita cuando todos los campos obligatorios tienen contenido
  bool get _isComplete => _filled == _fields.length;

  @override
  void dispose() {
    for (final controller in _fields) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onChanged(String field) {
    setState(() {
      _filled = countFilled(_fields);
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
      final user = await ref
          .read(authApiProvider)
          .register(
            RegisterData(
              email: _email.text.trim(),
              firstName: _firstName.text.trim(),
              lastName: _lastName.text.trim(),
              password: _password.text,
            ),
          );
      if (!mounted) return;
      context.go(
        '/login',
        extra: RegistrationNotice(email: user.email, message: '¡Cuenta creada! Ya puedes iniciar sesión.'),
      );
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

  void _goToLogin() => context.canPop() ? context.pop() : context.go('/login');

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AuthLayout(
      title: 'Crear cuenta',
      headline: 'Tu primera serie empieza aquí.',
      tagline: 'Completa tus datos: cada campo carga un disco.',
      filled: _filled,
      total: _fields.length,
      readyText: 'Barra cargada. Ya puedes guardar.',
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
              label: 'Nombres',
              controller: _firstName,
              maxLength: 60,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.givenName],
              errorText: _fieldErrors['firstName'],
              onChanged: (_) => _onChanged('firstName'),
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Apellidos',
              controller: _lastName,
              maxLength: 60,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.familyName],
              errorText: _fieldErrors['lastName'],
              onChanged: (_) => _onChanged('lastName'),
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Contraseña',
              controller: _password,
              isPassword: true,
              maxLength: 72,
              hint: 'Mínimo 8 caracteres',
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              errorText: _fieldErrors['password'],
              onChanged: (_) => _onChanged('password'),
              onSubmitted: (_) => _submit(),
            ),
            if (_error != null) ...[const SizedBox(height: 16), ErrorMessage(_error!)],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _isComplete && !_isSubmitting ? _submit : null,
              child: Text(_isSubmitting ? 'Guardando…' : 'Guardar'),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('¿Ya tienes cuenta?', style: TextStyle(color: palette.textMuted, fontSize: 16)),
                TextButton(onPressed: _goToLogin, child: const Text('Inicia sesión')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
