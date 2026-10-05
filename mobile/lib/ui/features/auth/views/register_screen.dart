import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../routing/routes.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/form_messages.dart';
import '../view_models/register_view_model.dart';
import '../view_models/registration_notice.dart';
import 'widgets/auth_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final RegisterViewModel _viewModel;
  final _email = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = RegisterViewModel(authRepository: context.read());
  }

  @override
  void dispose() {
    _viewModel.dispose();
    for (final controller in [_email, _firstName, _lastName, _password]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final user = await _viewModel.register();
    if (user == null || !mounted) return;
    context.go(
      Routes.login,
      extra: RegistrationNotice(email: user.email, message: '¡Cuenta creada! Ya puedes iniciar sesión.'),
    );
  }

  void _goToLogin() => context.canPop() ? context.pop() : context.go(Routes.login);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final vm = _viewModel;
        return AuthLayout(
          title: 'Crear cuenta',
          headline: 'Tu primera serie empieza aquí.',
          tagline: 'Completa tus datos: cada campo carga un disco.',
          filled: vm.filledCount,
          total: RegisterViewModel.totalFields,
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
                  errorText: vm.fieldErrors['email'],
                  onChanged: vm.updateEmail,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Nombres',
                  controller: _firstName,
                  maxLength: 60,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.givenName],
                  errorText: vm.fieldErrors['firstName'],
                  onChanged: vm.updateFirstName,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Apellidos',
                  controller: _lastName,
                  maxLength: 60,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.familyName],
                  errorText: vm.fieldErrors['lastName'],
                  onChanged: vm.updateLastName,
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
                  errorText: vm.fieldErrors['password'],
                  onChanged: vm.updatePassword,
                  onSubmitted: (_) => _submit(),
                ),
                if (vm.errorMessage != null) ...[const SizedBox(height: 16), ErrorMessage(vm.errorMessage!)],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: vm.canSubmit ? _submit : null,
                  child: Text(vm.isSubmitting ? 'Guardando…' : 'Guardar'),
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
      },
    );
  }
}
