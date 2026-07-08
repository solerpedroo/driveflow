import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/driveflow_brand_logo.dart';
import '../../../../shared/widgets/driveflow_glass_card.dart';
import '../../../../shared/widgets/driveflow_gradient_background.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';

/// Cadastro com e-mail, senha e nome.
class RegisterScreen extends HookConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmController = useTextEditingController();
    final obscurePassword = useState(true);
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    useEffect(() {
      SystemChrome.setSystemUIOverlayStyle(
        theme.brightness == Brightness.dark
            ? AppColors.darkOverlay
            : AppColors.lightOverlay,
      );
      return null;
    }, [theme.brightness]);

    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        final error = next.error;
        final message = error is AuthFailure
            ? error.message
            : AuthFailure.messageForError(error ?? 'Erro desconhecido');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        ref.read(authControllerProvider.notifier).clearError();
      }
    });

    Future<void> submit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;
      await ref.read(authControllerProvider.notifier).signUpWithEmail(
            email: emailController.text.trim(),
            password: passwordController.text,
            name: nameController.text.trim(),
          );
    }

    return DriveFlowGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: isLoading ? null : () => context.go(AppRoutes.login),
          ),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const DriveFlowBrandLogo(
                    size: LogoSize.small,
                    showTagline: false,
                  ),
                  const SizedBox(height: 24),
                  DriveFlowGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Criar conta',
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Comece a controlar lucro, custos e metas.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.secondaryLabel(theme),
                          ),
                        ),
                        const SizedBox(height: 24),
                        AuthTextField(
                          controller: nameController,
                          label: 'Nome completo',
                          hint: 'Seu nome',
                          textInputAction: TextInputAction.next,
                          prefixIcon: Icons.person_outline_rounded,
                          autofillHints: const [AutofillHints.name],
                          validator: (v) =>
                              Validators.requiredField(v, fieldName: 'Nome'),
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          controller: emailController,
                          label: 'E-mail',
                          hint: 'seu@email.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIcon: Icons.mail_outline_rounded,
                          autofillHints: const [AutofillHints.email],
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          controller: passwordController,
                          label: 'Senha',
                          hint: 'Mínimo 8 caracteres',
                          obscureText: obscurePassword.value,
                          textInputAction: TextInputAction.next,
                          prefixIcon: Icons.lock_outline_rounded,
                          validator: Validators.password,
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () =>
                                obscurePassword.value = !obscurePassword.value,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          controller: confirmController,
                          label: 'Confirmar senha',
                          obscureText: obscurePassword.value,
                          textInputAction: TextInputAction.done,
                          prefixIcon: Icons.lock_outline_rounded,
                          onFieldSubmitted: (_) => submit(),
                          validator: (value) {
                            if (value != passwordController.text) {
                              return 'As senhas não coincidem';
                            }
                            return Validators.password(value);
                          },
                        ),
                        const SizedBox(height: 24),
                        AuthPrimaryButton(
                          label: 'Cadastrar',
                          icon: Icons.person_add_rounded,
                          isLoading: isLoading,
                          onPressed: submit,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () => context.go(AppRoutes.login),
                      child: const Text('Já tenho conta'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
