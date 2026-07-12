import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/driver_type.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_message.dart';
import '../../domain/entities/sign_up_result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_password_checklist.dart';
import '../../../../shared/widgets/design_system/df_text_field.dart';
import '../../../../shared/widgets/driveflow_brand_logo.dart';
import '../../../../shared/widgets/driveflow_gradient_background.dart';
import '../../../onboarding/presentation/widgets/driver_type_picker.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_step_progress.dart';

enum _RegisterStep {
  driverType,
  name,
  email,
  password,
  confirmPassword,
}

extension on _RegisterStep {
  String get eyebrow => switch (this) {
        _RegisterStep.driverType => 'Comece pelo perfil',
        _RegisterStep.name => 'Identidade',
        _RegisterStep.email => 'Acesso',
        _RegisterStep.password => 'Segurança',
        _RegisterStep.confirmPassword => 'Confirmação',
      };

  String get headline => switch (this) {
        _RegisterStep.driverType => 'Como você\ntrabalha?',
        _RegisterStep.name => 'Qual é o\nseu nome?',
        _RegisterStep.email => 'Qual é o\nseu e-mail?',
        _RegisterStep.password => 'Crie uma\nsenha segura',
        _RegisterStep.confirmPassword => 'Confirme\nsua senha',
      };

  String subtitleFor(DriverType type) => switch (this) {
        _RegisterStep.driverType =>
          'Personalizamos o cockpit, os ganhos e o onboarding para a sua rotina.',
        _RegisterStep.name =>
          'É assim que o DriveFlow vai te cumprimentar no painel.',
        _RegisterStep.email =>
          'Usamos para entrar e proteger sua conta — sem spam.',
        _RegisterStep.password =>
          'Escolha uma senha forte. Os requisitos atualizam em tempo real.',
        _RegisterStep.confirmPassword => type.isTaxi
            ? 'Último passo — depois montamos seu painel de taxista.'
            : 'Último passo — depois você conecta apps e lucra com clareza.',
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

/// Cadastro outlier — mesma linguagem visual do login + etapas Mescla.
class RegisterScreen extends HookConsumerWidget {
  const RegisterScreen({super.key});

  static const _totalSteps = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
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

    final breath = useAnimationController(duration: DriveFlowMotion.pulse);
    useEffect(() {
      breath.repeat(reverse: true);
      return null;
    }, [breath]);

    useEffect(() {
      void listener() => passwordText.value = passwordController.text;
      passwordController.addListener(listener);
      return () => passwordController.removeListener(listener);
    }, [passwordController]);

    useEffect(() {
      SystemChrome.setSystemUIOverlayStyle(
        brightness == Brightness.dark
            ? AppColors.darkOverlay
            : AppColors.lightOverlay,
      );
      return null;
    }, [brightness]);

    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        final error = next.error;
        final message = error is AuthFailure
            ? error.message
            : FailureMessage.forObject(error);
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
      if (confirmController.text != passwordController.text) return;
      FocusScope.of(context).unfocus();
      final outcome =
          await ref.read(authControllerProvider.notifier).signUpWithEmail(
                email: emailController.text.trim(),
                password: passwordController.text,
                name: nameController.text.trim(),
                driverType: driverType.value,
              );
      if (!context.mounted || outcome == null) return;
      if (outcome is SignUpAwaitingEmailConfirmation) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Conta criada! Confirme o e-mail ${outcome.email} antes de entrar.',
            ),
          ),
        );
        context.go(AppRoutes.login);
      }
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

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return DriveFlowGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.lg,
                  AppSpacing.screenHorizontal,
                  AppSpacing.xxl + bottomInset * 0.12,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: -36,
                        right: -56,
                        child: _AtmosphereBloom(
                          animation: breath,
                          size: 220,
                        ),
                      ),
                      Positioned(
                        bottom: 80,
                        left: -70,
                        child: _AtmosphereBloom(
                          animation: breath,
                          size: 180,
                          phase: 0.45,
                          accent: AppColors.brandGlow,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _RegisterTopBar(
                            onBack: isLoading ? null : goBack,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AuthStepProgress(
                            currentStep: stepIndex.value,
                            totalSteps: _totalSteps,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AnimatedSwitcher(
                            duration: DriveFlowMotion.normal,
                            switchInCurve: DriveFlowMotion.enter,
                            switchOutCurve: DriveFlowMotion.exit,
                            child: Column(
                              key: ValueKey('copy-$step'),
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  step.eyebrow,
                                  style: AppTypography.labelCaps(brightness),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  step.headline,
                                  style: AppTypography.iosLargeTitle(brightness)
                                      .copyWith(
                                    fontSize: 36,
                                    height: 1.05,
                                    letterSpacing: -1.3,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                _EditorialRule(),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  step.subtitleFor(driverType.value),
                                  style: AppTypography.iosBody(brightness)
                                      .copyWith(
                                    color: AppColors.secondaryLabel(theme),
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (step == _RegisterStep.driverType) ...[
                            const SizedBox(height: AppSpacing.xl),
                            _ProfileHintCard(driverType: driverType.value),
                          ],
                          const SizedBox(height: AppSpacing.xl),
                          DfCard(
                            variant: DfCardVariant.glass,
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.xl,
                              AppSpacing.lg,
                              AppSpacing.xl,
                              AppSpacing.xl,
                            ),
                            child: Form(
                              key: formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      AuthStepIcon(icon: step.icon),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Text(
                                          step.isLast
                                              ? 'Finalize seu acesso'
                                              : 'Preencha para continuar',
                                          style: AppTypography.iosHeadline(
                                            brightness,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  AnimatedSwitcher(
                                    duration: DriveFlowMotion.normal,
                                    switchInCurve: DriveFlowMotion.enter,
                                    switchOutCurve: DriveFlowMotion.exit,
                                    transitionBuilder: (child, animation) {
                                      final offset = Tween<Offset>(
                                        begin: const Offset(0.05, 0),
                                        end: Offset.zero,
                                      ).animate(animation);
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position: offset,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: KeyedSubtree(
                                      key: ValueKey(step),
                                      child: buildStepBody(),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xl),
                                  DfButton(
                                    label: step.isLast
                                        ? 'Criar conta'
                                        : 'Continuar',
                                    icon: Icons.arrow_forward_rounded,
                                    trailingIcon: true,
                                    isLoading: isLoading && step.isLast,
                                    variant: DfButtonVariant.gradient,
                                    onPressed: isLoading ? null : goNext,
                                  ),
                                  if (step.isLast) ...[
                                    const SizedBox(height: AppSpacing.md),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.verified_user_outlined,
                                          size: 14,
                                          color:
                                              AppColors.secondaryLabel(theme),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Acesso seguro · dados só seus',
                                          style: AppTypography.iosCaption(
                                            brightness,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          if (stepIndex.value > 0) ...[
                            const SizedBox(height: AppSpacing.sm),
                            DfButton(
                              label: 'Voltar',
                              icon: Icons.arrow_back_rounded,
                              variant: DfButtonVariant.tonal,
                              onPressed: isLoading ? null : goBack,
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xl),
                          _LoginFooter(
                            enabled: !isLoading,
                            onPressed: () => context.go(AppRoutes.login),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RegisterTopBar extends StatelessWidget {
  const _RegisterTopBar({required this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
          style: IconButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        const DriveFlowBrandLogo(
          size: LogoSize.small,
          showTagline: false,
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 1,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.brandBlue.withValues(alpha: 0.16),
                AppColors.brandGlow.withValues(alpha: 0.22),
              ],
            ),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: AppColors.brandBlue.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 14,
                color: AppColors.brandBlue,
              ),
              const SizedBox(width: 6),
              Text(
                'Tudo incluso',
                style: AppTypography.iosFootnote(theme.brightness).copyWith(
                  color: AppColors.brandBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EditorialRule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            gradient: AppGradients.brand,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.separator(Theme.of(context)),
          ),
        ),
      ],
    );
  }
}

class _ProfileHintCard extends StatelessWidget {
  const _ProfileHintCard({required this.driverType});

  final DriverType driverType;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isTaxi = driverType.isTaxi;

    return AnimatedSwitcher(
      duration: DriveFlowMotion.normal,
      child: DecoratedBox(
        key: ValueKey(driverType),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: AppGradients.heroWealth,
          boxShadow: [
            BoxShadow(
              color: AppColors.brandBlue.withValues(alpha: 0.24),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isTaxi
                      ? Icons.local_taxi_rounded
                      : Icons.hub_outlined,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTaxi ? 'Modo taxista' : 'Modo apps de corrida',
                      style: AppTypography.iosHeadline(brightness).copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isTaxi
                          ? 'Painel manual — corridas, custos e lucro sem integrações.'
                          : 'Uber, 99 e InDrive opcionais — lucro líquido com clareza.',
                      style: AppTypography.iosFootnote(brightness).copyWith(
                        color: Colors.white.withValues(alpha: 0.78),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginFooter extends StatelessWidget {
  const _LoginFooter({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          height: 1,
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          color: AppColors.separator(theme),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Já tem acesso?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryLabel(theme),
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: enabled ? onPressed : null,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 8,
                ),
                child: Text(
                  'Entrar',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: enabled
                        ? AppColors.brandBlue
                        : AppColors.secondaryLabel(theme),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AtmosphereBloom extends StatelessWidget {
  const _AtmosphereBloom({
    required this.animation,
    required this.size,
    this.phase = 0,
    this.accent,
  });

  final Animation<double> animation;
  final double size;
  final double phase;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final core = accent ?? AppColors.brandBlue;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final raw = (animation.value + phase) % 1.0;
        final t = Curves.easeInOut.transform(raw);
        final scale = 0.88 + (t * 0.16);
        final opacity = 0.16 + (t * 0.14);
        return Transform.scale(
          scale: scale,
          child: Opacity(opacity: opacity, child: child),
        );
      },
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                core.withValues(alpha: 0.5),
                AppColors.brandGlow.withValues(alpha: 0.14),
                Colors.transparent,
              ],
              stops: const [0.0, 0.42, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
