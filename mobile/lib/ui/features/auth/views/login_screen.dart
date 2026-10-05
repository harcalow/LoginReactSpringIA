import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../routing/routes.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/form_messages.dart';
import '../view_models/login_view_model.dart';
import '../view_models/registration_notice.dart';
import 'widgets/auth_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.notice});

  /// Mensaje y correo que llegan desde el registro.
  final RegistrationNotice? notice;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginViewModel _viewModel;
  late final TextEditingController _email;
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initialEmail = widget.notice?.email ?? '';
    _viewModel = LoginViewModel(authRepository: context.read(), initialEmail: initialEmail);
    _email = TextEditingController(text: initialEmail);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    _viewModel.login();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final notice = widget.notice;

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final vm = _viewModel;
        return AuthLayout(
          title: 'Iniciar sesión',
          headline: 'Hoy también se entrena.',
          tagline: 'Inicia sesión para seguir con tu plan.',
          filled: vm.filledCount,
          total: LoginViewModel.totalFields,
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
                  errorText: vm.fieldErrors['email'],
                  onChanged: vm.updateEmail,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Contraseña',
                  controller: _password,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  errorText: vm.fieldErrors['password'],
                  onChanged: vm.updatePassword,
                  onSubmitted: (_) => _submit(),
                ),
                if (vm.errorMessage != null) ...[const SizedBox(height: 16), ErrorMessage(vm.errorMessage!)],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: vm.canSubmit ? _submit : null,
                  child: Text(vm.isSubmitting ? 'Ingresando…' : 'Ingresar'),
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
                    OutlinedButton(onPressed: () => context.push(Routes.register), child: const Text('Crear cuenta')),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
