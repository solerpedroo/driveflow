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
import '../../../../core/utils/df_haptics.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_password_checklist.dart';
import '../../../../shared/widgets/design_system/df_text_field.dart';
import '../../../onboarding/presentation/widgets/driver_type_picker.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_hero_layout.dart';
import '../widgets/auth_step_progress.dart';

enum _RegisterStep {
  driverType,
  name,
  email,
  password,
  confirmPassword,
}

extension on _RegisterStep {
  String get headline => switch (this) {
        _RegisterStep.driverType => 'Como você\ntrabalha?',
        _RegisterStep.name => 'Qual é o\nseu nome?',
        _RegisterStep.email => 'Qual é o\nseu e-mail?',
        _RegisterStep.password => 'Crie uma\nsenha segura',
        _RegisterStep.confirmPassword => 'Confirme\nsua senha',
      };

  String subtitleFor(DriverType type) => switch (this) {
        _RegisterStep.driverType =>
          'Personalizamos o painel e o onboarding para a sua rotina.',
        _RegisterStep.name =>
          'Como prefere ser chamado no DriveFlow.',
        _RegisterStep.email =>
          'Usamos para entrar e proteger sua conta.',
        _RegisterStep.password =>
          'Escolha uma senha forte — você verá os requisitos em tempo real.',
        _RegisterStep.confirmPassword => type.isTaxi
            ? 'Último passo — depois montamos seu painel de taxista.'
            : 'Último passo — depois você conecta apps e começa a lucrar com clareza.',
      };

  IconData get icon => switch (this) {
        _RegisterStep.driverType => Icons.work_outline_rounded,
        _RegisterStep.name => Icons.person_outline_rounded,
        _RegisterStep.email => Icons.mail_outline_rounded,
        _RegisterStep.password => Icons.lock_outline_rounded,
        _RegisterStep.confirmPassword => Icons.verified_user_outlined,
      };

  bool get isLast => this == _RegisterStep.confirmPassword;
}

/// Cadastro em etapas — padrão Mescla Invest (uma pergunta por tela).
class RegisterScreen extends HookConsumerWidget {
  const RegisterScreen({super.key});

  static const _totalSteps = 5;

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
    final stepIndex = useState(0);
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    final step = _RegisterStep.values[stepIndex.value];

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

    bool validateCurrentStep() {
      switch (step) {
        case _RegisterStep.driverType:
          return true;
        case _RegisterStep.name:
          return Validators.requiredField(
                nameController.text,
                fieldName: 'Nome',
              ) ==
              null;
        case _RegisterStep.email:
          return Validators.email(emailController.text) == null;
        case _RegisterStep.password:
          return Validators.password(passwordController.text) == null;
        case _RegisterStep.confirmPassword:
          if (confirmController.text != passwordController.text) {
            return false;
          }
          return Validators.password(confirmController.text) == null;
      }
    }

    Future<void> submit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;
      if (Validators.password(passwordController.text) != null) {
        stepIndex.value = _RegisterStep.password.index;
        return;
      }
      if (confirmController.text != passwordController.text) {
        return;
      }
      await ref.read(authControllerProvider.notifier).signUpWithEmail(
            email: emailController.text.trim(),
            password: passwordController.text,
            name: nameController.text.trim(),
            driverType: driverType.value,
          );
    }

    void goNext() {
      if (isLoading) return;
      final valid = formKey.currentState?.validate() ?? false;
      if (!valid || !validateCurrentStep()) {
        DfHaptics.light();
        return;
      }
      DfHaptics.light();
      if (step.isLast) {
        submit();
        return;
      }
      stepIndex.value = stepIndex.value + 1;
    }

    void goBack() {
      if (isLoading) return;
      DfHaptics.light();
      if (stepIndex.value == 0) {
        context.go(AppRoutes.login);
        return;
      }
      stepIndex.value = stepIndex.value - 1;
    }

    Widget buildStepBody() {
      return switch (step) {
        _RegisterStep.driverType => DriverTypePicker(
            selected: driverType.value,
            onChanged: (type) {
              DfHaptics.selection();
              driverType.value = type;
            },
            showHeader: false,
          ),
        _RegisterStep.name => DfTextField(
            controller: nameController,
            label: 'Nome completo',
            hint: 'Seu nome',
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.person_outline_rounded,
            autofillHints: const [AutofillHints.name],
            autofocus: true,
            validator: (v) => Validators.requiredField(v, fieldName: 'Nome'),
            onFieldSubmitted: (_) => goNext(),
          ),
        _RegisterStep.email => DfTextField(
            controller: emailController,
            label: 'E-mail',
            hint: 'seu@email.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.mail_outline_rounded,
            autofillHints: const [AutofillHints.email],
            autofocus: true,
            validator: Validators.email,
            onFieldSubmitted: (_) => goNext(),
          ),
        _RegisterStep.password => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DfTextField(
                controller: passwordController,
                label: 'Senha',
                hint: 'Crie uma senha segura',
                obscureText: obscurePassword.value,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.lock_outline_rounded,
                autofocus: true,
                validator: Validators.password,
                onFieldSubmitted: (_) => goNext(),
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
            ],
          ),
        _RegisterStep.confirmPassword => DfTextField(
            controller: confirmController,
            label: 'Confirmar senha',
            obscureText: obscureConfirm.value,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.lock_outline_rounded,
            autofocus: true,
            onFieldSubmitted: (_) => goNext(),
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
              onPressed: () => obscureConfirm.value = !obscureConfirm.value,
            ),
          ),
      };
    }

    return AuthHeroLayout(
      headline: step.headline,
      subtitle: step.subtitleFor(driverType.value),
      headerChild: AuthStepProgress(
        currentStep: stepIndex.value,
        totalSteps: _totalSteps,
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: isLoading ? null : goBack,
      ),
      middleChild: null,
      formChild: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthStepIcon(icon: step.icon),
            const SizedBox(height: AppSpacing.lg),
            AnimatedSwitcher(
              duration: DriveFlowMotion.normal,
              switchInCurve: DriveFlowMotion.enter,
              switchOutCurve: DriveFlowMotion.exit,
              transitionBuilder: (child, animation) {
                final offset = Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: offset, child: child),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(step),
                child: buildStepBody(),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            DfButton(
              label: step.isLast ? 'Cadastrar' : 'Continuar',
              icon: step.isLast
                  ? Icons.person_add_rounded
                  : Icons.arrow_forward_rounded,
              isLoading: isLoading && step.isLast,
              variant: DfButtonVariant.gradient,
              onPressed: isLoading ? null : goNext,
            ),
          ],
        ),
      ),
      bottomChild: stepIndex.value > 0
          ? DfButton(
              label: 'Voltar',
              icon: Icons.arrow_back_rounded,
              variant: DfButtonVariant.outlined,
              onPressed: isLoading ? null : goBack,
            )
          : null,
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
