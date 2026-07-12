import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/driveflow_brand_logo.dart';

/// Chip “Tudo incluso” — mesma linguagem do login/cadastro.
class AuthInclusivityChip extends StatelessWidget {
  const AuthInclusivityChip({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
    );
  }
}

/// Top bar de fluxos auth/onboarding — back opcional + logo + chip.
class AuthFlowTopBar extends StatelessWidget {
  const AuthFlowTopBar({
    super.key,
    this.onBack,
    this.showChip = true,
  });

  final VoidCallback? onBack;
  final bool showChip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        if (onBack != null) ...[
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
        const DriveFlowBrandLogo(
          size: LogoSize.small,
          showTagline: false,
        ),
        const Spacer(),
        if (showChip) const AuthInclusivityChip(),
      ],
    );
  }
}

/// Traço editorial brand → separator.
class AuthEditorialRule extends StatelessWidget {
  const AuthEditorialRule({super.key});

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

/// Bloco de copy: eyebrow → headline → rule → subtitle.
class AuthEditorialCopy extends StatelessWidget {
  const AuthEditorialCopy({
    required this.eyebrow,
    required this.headline,
    required this.subtitle,
    super.key,
  });

  final String eyebrow;
  final String headline;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(eyebrow, style: AppTypography.labelCaps(brightness)),
        const SizedBox(height: AppSpacing.md),
        Text(
          headline,
          style: AppTypography.iosLargeTitle(brightness).copyWith(
            fontSize: 36,
            height: 1.05,
            letterSpacing: -1.2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const AuthEditorialRule(),
        const SizedBox(height: AppSpacing.md),
        Text(
          subtitle,
          style: AppTypography.iosBody(brightness).copyWith(
            color: AppColors.secondaryLabel(theme),
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

/// Blooms atmosféricos do login/cadastro.
class AuthAtmosphereBlooms extends StatelessWidget {
  const AuthAtmosphereBlooms({required this.animation, super.key});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -36,
            right: -56,
            child: _AuthAtmosphereBloom(
              animation: animation,
              size: 220,
            ),
          ),
          Positioned(
            bottom: 80,
            left: -70,
            child: _AuthAtmosphereBloom(
              animation: animation,
              size: 180,
              phase: 0.45,
              accent: AppColors.brandGlow,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthAtmosphereBloom extends StatelessWidget {
  const _AuthAtmosphereBloom({
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
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              core.withValues(alpha: 0.55),
              core.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
