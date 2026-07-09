import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_elevation.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

enum DfCardVariant { glass, elevated, hero }

/// Cartão do Design System v2 — glass, elevated e hero (FitCal tier).
class DfCard extends StatelessWidget {
  const DfCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    this.onTap,
    this.semanticLabel,
    this.variant = DfCardVariant.glass,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final DfCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Widget card = switch (variant) {
      DfCardVariant.hero => _HeroCard(
          isDark: isDark,
          padding: padding,
          child: child,
        ),
      DfCardVariant.elevated => _ElevatedCard(
          isDark: isDark,
          padding: padding,
          child: child,
        ),
      DfCardVariant.glass => _GlassCard(
          isDark: isDark,
          padding: padding,
          child: child,
        ),
    };

    final content = onTap == null
        ? card
        : Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: AppRadius.xlAll,
              child: card,
            ),
          );

    if (semanticLabel == null) return content;
    return Semantics(label: semanticLabel, button: onTap != null, child: content);
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.isDark,
    required this.padding,
    required this.child,
  });

  final bool isDark;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isDark ? AppColors.glassBorder : AppColors.glassBorderLight;
    final fill = isDark
        ? AppColors.slate.withValues(alpha: 0.45)
        : Colors.white.withValues(alpha: 0.78);

    return ClipRRect(
      borderRadius: AppRadius.xlAll,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: AppRadius.xlAll,
            border: Border.all(color: borderColor),
            boxShadow: AppElevation.glassShadow(
              isDark ? Brightness.dark : Brightness.light,
            ),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class _ElevatedCard extends StatelessWidget {
  const _ElevatedCard({
    required this.isDark,
    required this.padding,
    required this.child,
  });

  final bool isDark;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnight : Colors.white,
        borderRadius: AppRadius.xlAll,
        border: Border.all(
          color: isDark
              ? AppColors.glassBorder
              : AppColors.glassBorderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.skyBlue)
                .withValues(alpha: isDark ? 0.28 : 0.10),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.isDark,
    required this.padding,
    required this.child,
  });

  final bool isDark;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.xlAll,
        gradient: AppGradients.heroCardAccent(
          isDark ? Brightness.dark : Brightness.light,
        ),
        border: Border.all(
          color: AppColors.skyBlue.withValues(alpha: isDark ? 0.28 : 0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.skyBlue.withValues(alpha: isDark ? 0.18 : 0.12),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.xlAll,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
