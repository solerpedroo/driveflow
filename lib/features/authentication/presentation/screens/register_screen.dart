import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/driver_type.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_password_checklist.dart';
import '../../../../shared/widgets/design_system/df_staggered_entrance.dart';
import '../../../../shared/widgets/design_system/df_text_field.dart';
import '../../../onboarding/presentation/widgets/driver_type_picker.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_benefits_strip.dart';
import '../widgets/auth_hero_layout.dart';

/// Cadastro — escolha motorista de app ou taxista + checklist de senha.
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
    final obscureConfirm = useState(true);
    final passwordText = useState('');
    final driverType = useState(DriverType.rideShare);
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    useEffect(() {
      void listener() => passwordText.value = passwordController.text;
      passwordController.addListener(listener);
      return () => passwordController.removeListener(listener);
    }, [passwordController]);

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
            driverType: driverType.value,
          );
    }

    return AuthHeroLayout(
      headline: 'Crie sua\nconta DriveFlow',
      subtitle: driverType.value.isTaxi
          ? 'Painel manual para taxistas — corridas, custos e lucro sem integrações.'
          : 'Controle ganhos de app, despesas e metas com integrações opcionais.',
      middleChild: const AuthBenefitsStrip(),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: isLoading ? null : () => context.go(AppRoutes.login),
      ),
      formChild: Form(
        key: formKey,
        child: DfStaggeredEntrance(
          children: [
            DriverTypePicker(
              selected: driverType.value,
              onChanged: (type) => driverType.value = type,
            ),
            const SizedBox(height: AppSpacing.xl),
            DfTextField(
              controller: nameController,
              label: 'Nome completo',
              hint: 'Seu nome',
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.person_outline_rounded,
              autofillHints: const [AutofillHints.name],
              validator: (v) =>
                  Validators.requiredField(v, fieldName: 'Nome'),
            ),
            const SizedBox(height: AppSpacing.lg),
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
              hint: 'Crie uma senha segura',
              obscureText: obscurePassword.value,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.lock_outline_rounded,
              validator: Validators.password,
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
            const SizedBox(height: AppSpacing.md),
            DfPasswordChecklist(password: passwordText.value),
            const SizedBox(height: AppSpacing.lg),
            DfTextField(
              controller: confirmController,
              label: 'Confirmar senha',
              obscureText: obscureConfirm.value,
              textInputAction: TextInputAction.done,
              prefixIcon: Icons.lock_outline_rounded,
              onFieldSubmitted: (_) => submit(),
              validator: (value) {
                if (value != passwordController.text) {
                  return 'As senhas não coincidem';
                }
                return Validators.password(value);
              },
              suffixIcon: IconButton(
                icon: AnimatedSwitcher(
                  duration: DriveFlowMotion.fast,
                  child: Icon(
                    obscureConfirm.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    key: ValueKey(obscureConfirm.value),
                    size: 22,
                  ),
                ),
                onPressed: () =>
                    obscureConfirm.value = !obscureConfirm.value,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            DfButton(
              label: 'Cadastrar',
              icon: Icons.person_add_rounded,
              isLoading: isLoading,
              variant: DfButtonVariant.gradient,
              onPressed: submit,
            ),
          ],
        ),
      ),
      footer: Center(
        child: TextButton(
          onPressed: isLoading ? null : () => context.go(AppRoutes.login),
          child: Text(
            'Já tenho conta',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryLabel(theme),
            ),
          ),
        ),
      ),
    );
  }
}
