import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_elevation.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/onboarding_slide.dart';

/// Card ilustrado de um passo do onboarding.
class OnboardingSlideView extends StatelessWidget {
  const OnboardingSlideView({
    required this.slide,
    this.compact = false,
    super.key,
  });

  final OnboardingSlide slide;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final accent = slide.accent ?? AppColors.brandBlue;

    final orb = Container(
      width: compact ? 96 : 88,
      height: compact ? 96 : 88,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.22),
            accent.withValues(alpha: 0.08),
          ],
        ),
        border: Border.fromBorderSide(AppElevation.hairline(brightness)),
        boxShadow: AppElevation.surfaceCard(brightness),
      ),
      child: Icon(slide.icon, size: compact ? 44 : 40, color: accent),
    );

    if (compact) {
      return Center(child: orb);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        orb,
        const SizedBox(height: AppSpacing.xxl),
        Text(
          slide.title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
            height: 1.15,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          slide.body,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.secondaryLabel(theme),
            height: 1.55,
          ),
        ),
      ],
    );
  }
}
