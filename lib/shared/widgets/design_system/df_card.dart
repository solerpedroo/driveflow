import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_elevation.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

enum DfCardVariant { glass, elevated, hero, brand }

/// Cartão premium — surface-card, glass, hero tint e brand gradient.
class DfCard extends StatelessWidget {
  const DfCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    this.onTap,
    this.semanticLabel,
    this.variant = DfCardVariant.elevated,
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
      DfCardVariant.brand => _BrandCard(padding: padding, child: child),
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
              borderRadius: AppRadius.lgAll,
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
    final fill = isDark
        ? AppColors.slate.withValues(alpha: 0.55)
        : Colors.white.withValues(alpha: 0.78);

    return ClipRRect(
      borderRadius: AppRadius.lgAll,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: AppRadius.lgAll,
            border: Border.all(
              color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
            ),
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
    final brightness = isDark ? Brightness.dark : Brightness.light;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.surfaceCardTopLight(brightness),
        borderRadius: AppRadius.lgAll,
        border: Border.all(
          color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
        ),
        boxShadow: AppElevation.surfaceCard(brightness),
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
        borderRadius: AppRadius.lgAll,
        gradient: AppGradients.heroCardAccent(
          isDark ? Brightness.dark : Brightness.light,
        ),
        border: Border.all(
          color: AppColors.brandBlue.withValues(alpha: isDark ? 0.30 : 0.15),
        ),
        boxShadow: AppElevation.surfaceCard(
          isDark ? Brightness.dark : Brightness.light,
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _BrandCard extends StatelessWidget {
  const _BrandCard({required this.padding, required this.child});

  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.xlAll,
        gradient: AppGradients.brand,
        boxShadow: AppElevation.brandGlow(Theme.of(context).brightness),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}
