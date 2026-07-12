import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/product_story.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_staggered_entrance.dart';
import '../../../../shared/widgets/design_system/df_text_field.dart';
import '../../../../shared/widgets/driveflow_brand_logo.dart';
import '../../../../shared/widgets/driveflow_gradient_background.dart';
import '../providers/auth_providers.dart';

/// Login outlier — composição cinematográfica brand-first, SaaS pago, sem Google.
class LoginScreen extends HookConsumerWidget {
  const LoginScreen({
    super.key,
    this.authRepositoryForTesting,
  });

  final Object? authRepositoryForTesting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final obscurePassword = useState(true);
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    final breath = useAnimationController(duration: DriveFlowMotion.pulse);
    useEffect(() {
      breath.repeat(reverse: true);
      return null;
    }, [breath]);

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
            : AuthFailure.messageForError(error ?? 'Erro desconhecido');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        ref.read(authControllerProvider.notifier).clearError();
      }
    });

    Future<void> submit() async {
      if (!(formKey.currentState?.validate() ?? false)) {
        DfHaptics.light();
        return;
      }
      DfHaptics.light();
      FocusScope.of(context).unfocus();
      await ref.read(authControllerProvider.notifier).signInWithEmail(
            email: emailController.text.trim(),
            password: passwordController.text,
          );
    }

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return DriveFlowGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tall = constraints.maxHeight > 720;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.lg,
                  AppSpacing.screenHorizontal,
                  AppSpacing.xxl + bottomInset * 0.15,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: -40,
                        right: -48,
                        child: _AtmosphereBloom(
                          animation: breath,
                          size: 240,
                          phase: 0,
                        ),
                      ),
                      Positioned(
                        bottom: tall ? 120 : 40,
                        left: -80,
                        child: _AtmosphereBloom(
                          animation: breath,
                          size: 200,
                          phase: 0.5,
                          accent: AppColors.brandGlow,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _LoginTopBar(),
                          SizedBox(height: tall ? AppSpacing.xxxl : AppSpacing.xl),
                          DfStaggeredEntrance(
                            initialDelay: const Duration(milliseconds: 60),
                            delayBetween: const Duration(milliseconds: 55),
                            children: [
                              const _BrandHero(),
                              const SizedBox(height: AppSpacing.xl),
                              const _EditorialRule(),
                              const SizedBox(height: AppSpacing.xl),
                              Text(
                                'Ganhos, custos e metas — lucidez financeira\npara quem vive na rua.',
                                style: AppTypography.iosBody(brightness).copyWith(
                                  color: AppColors.secondaryLabel(theme),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              const _ValuePills(),
                              const SizedBox(height: AppSpacing.xl),
                              const _ProfitPreviewCard(),
                              const SizedBox(height: AppSpacing.lg),
                              const _TestimonialWhisper(),
                              SizedBox(height: tall ? AppSpacing.xxl : AppSpacing.xl),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'Acesse sua conta',
                                        style: AppTypography.iosHeadline(
                                          brightness,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        'E-mail e senha do seu plano DriveFlow.',
                                        style: AppTypography.iosFootnote(
                                          brightness,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      DfTextField(
                                        controller: emailController,
                                        label: 'E-mail',
                                        hint: 'seu@email.com',
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        prefixIcon: Icons.mail_outline_rounded,
                                        autofillHints: const [
                                          AutofillHints.email,
                                        ],
                                        autofocus: true,
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
                                        autofillHints: const [
                                          AutofillHints.password,
                                        ],
                                        validator: Validators.password,
                                        onFieldSubmitted: (_) => submit(),
                                        suffixIcon: IconButton(
                                          tooltip: obscurePassword.value
                                              ? 'Mostrar senha'
                                              : 'Ocultar senha',
                                          icon: AnimatedSwitcher(
                                            duration: DriveFlowMotion.fast,
                                            child: Icon(
                                              obscurePassword.value
                                                  ? Icons
                                                      .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              key: ValueKey(
                                                obscurePassword.value,
                                              ),
                                              size: 22,
                                            ),
                                          ),
                                          onPressed: () => obscurePassword
                                              .value = !obscurePassword.value,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.xl),
                                      DfButton(
                                        label: 'Entrar no painel',
                                        icon: Icons.arrow_forward_rounded,
                                        trailingIcon: true,
                                        isLoading: isLoading,
                                        variant: DfButtonVariant.gradient,
                                        onPressed: submit,
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.verified_user_outlined,
                                            size: 14,
                                            color: AppColors.secondaryLabel(
                                              theme,
                                            ),
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
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              _CreateAccountFooter(
                                enabled: !isLoading,
                                onPressed: () =>
                                    context.go(AppRoutes.register),
                              ),
                            ],
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

class _LoginTopBar extends StatelessWidget {
  const _LoginTopBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
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
              Icon(
                Icons.workspace_premium_rounded,
                size: 14,
                color: AppColors.brandBlue,
              ),
              const SizedBox(width: 6),
              Text(
                'Plano Pro',
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

/// Brand como herói tipográfico — não só nav.
class _BrandHero extends StatelessWidget {
  const _BrandHero();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cockpit financeiro',
          style: AppTypography.labelCaps(brightness),
        ),
        const SizedBox(height: AppSpacing.md),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Drive',
                style: GoogleFonts.geist(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.8,
                  height: 0.98,
                  color: brightness == Brightness.dark
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
              ),
              TextSpan(
                text: 'Flow',
                style: GoogleFonts.geist(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.8,
                  height: 0.98,
                  color: AppColors.brandBlue,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Lucro claro.\nDecisão inteligente.',
          style: AppTypography.iosLargeTitle(brightness).copyWith(
            fontSize: 28,
            height: 1.12,
            letterSpacing: -0.9,
            color: AppColors.secondaryLabel(theme).withValues(alpha: 0.92),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _EditorialRule extends StatelessWidget {
  const _EditorialRule();

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

class _ValuePills extends StatelessWidget {
  const _ValuePills();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final benefit in ProductStory.authBenefits)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.mutedSurface(theme),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: AppColors.brandBlue.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(benefit.icon, size: 15, color: AppColors.brandBlue),
                const SizedBox(width: 6),
                Text(
                  benefit.label,
                  style: AppTypography.iosFootnote(theme.brightness).copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Âncora visual do produto — preview do painel (Wallet).
class _ProfitPreviewCard extends StatelessWidget {
  const _ProfitPreviewCard();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.xlAll,
        gradient: AppGradients.heroWealth,
        boxShadow: [
          BoxShadow(
            color: AppColors.brandBlue.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Lucro de hoje',
                  style: AppTypography.labelCaps(brightness).copyWith(
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'Ao vivo',
                    style: AppTypography.iosCaption(brightness).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'R\$ 248,40',
              style: AppTypography.metric(
                brightness,
                fontSize: 34,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Expanded(
                  child: _PreviewStat(label: 'Corridas', value: '14'),
                ),
                Container(
                  width: 1,
                  height: 28,
                  color: Colors.white.withValues(alpha: 0.16),
                ),
                const Expanded(
                  child: _PreviewStat(label: 'Por hora', value: 'R\$ 42'),
                ),
                Container(
                  width: 1,
                  height: 28,
                  color: Colors.white.withValues(alpha: 0.16),
                ),
                const Expanded(
                  child: _PreviewStat(label: 'Meta', value: '82%'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewStat extends StatelessWidget {
  const _PreviewStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
        ],
      ),
    );
  }
}

class _TestimonialWhisper extends StatelessWidget {
  const _TestimonialWhisper();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.format_quote_rounded,
          size: 20,
          color: AppColors.brandBlue.withValues(alpha: 0.55),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            ProductStory.testimonial.replaceAll('"', ''),
            style: AppTypography.iosFootnote(brightness).copyWith(
              fontStyle: FontStyle.italic,
              height: 1.45,
              color: AppColors.secondaryLabel(theme),
            ),
          ),
        ),
      ],
    );
  }
}

class _CreateAccountFooter extends StatelessWidget {
  const _CreateAccountFooter({
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
              'Ainda não tem acesso?',
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
                  'Criar conta',
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
        final opacity = 0.18 + (t * 0.16);
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
