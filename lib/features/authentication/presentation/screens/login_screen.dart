import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_staggered_entrance.dart';
import '../../../../shared/widgets/design_system/df_text_field.dart';
import '../../../../shared/widgets/driveflow_brand_logo.dart';
import '../../../../shared/widgets/driveflow_gradient_background.dart';
import '../providers/auth_providers.dart';

/// Login com e-mail/senha e Google OAuth.
class LoginScreen extends HookConsumerWidget {
  const LoginScreen({
    super.key,
    this.authRepositoryForTesting,
  });

  /// Hook para testes — bypass de providers quando necessário.
  final Object? authRepositoryForTesting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
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
      await ref.read(authControllerProvider.notifier).signInWithEmail(
            email: emailController.text.trim(),
            password: passwordController.text,
          );
    }

    return DriveFlowGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.screenHorizontal,
              AppSpacing.screenHorizontal,
              AppSpacing.xxl,
            ),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const DriveFlowBrandLogo(size: LogoSize.medium),
                  const SizedBox(height: AppSpacing.xl),
                  DfCard(
                    child: DfStaggeredEntrance(
                      children: [
                        Text(
                          'Entrar',
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Acesse sua central financeira de motorista.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.secondaryLabel(theme),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        DfTextField(
                          controller: emailController,
                          label: 'E-mail',
                          hint: 'seu@email.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIcon: Icons.mail_outline_rounded,
                          autofillHints: const [AutofillHints.email],
                          validator: Validators.email,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        DfTextField(
                          controller: passwordController,
                          label: 'Senha',
                          hint: '••••••••',
                          obscureText: obscurePassword.value,
                          textInputAction: TextInputAction.done,
                          prefixIcon: Icons.lock_outline_rounded,
                          autofillHints: const [AutofillHints.password],
                          validator: Validators.password,
                          onFieldSubmitted: (_) => submit(),
                          suffixIcon: IconButton(
                            icon: AnimatedSwitcher(
                              duration: DriveFlowMotion.fast,
                              child: Icon(
                                obscurePassword.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                key: ValueKey(obscurePassword.value),
                                size: 22,
                              ),
                            ),
                            onPressed: () =>
                                obscurePassword.value = !obscurePassword.value,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        DfButton(
                          label: 'Entrar',
                          icon: Icons.login_rounded,
                          isLoading: isLoading,
                          onPressed: submit,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        DfButton(
                          label: 'Continuar com Google',
                          isLoading: isLoading,
                          leading: const _GoogleMark(),
                          variant: DfButtonVariant.outlined,
                          onPressed: () => ref
                              .read(authControllerProvider.notifier)
                              .signInWithGoogle(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Novo por aqui?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondaryLabel(theme),
                        ),
                      ),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => context.go(AppRoutes.register),
                        child: const Text('Criar conta'),
                      ),
                    ],
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

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'G',
        style: TextStyle(
          color: Color(0xFF4285F4),
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}
