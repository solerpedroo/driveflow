import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_elevation.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

enum DfCardVariant { grouped, elevated, glass, hero, brand }

/// Cartão híbrido — grouped iOS + surface ReuniAI + hero Mescla.
class DfCard extends StatelessWidget {
  const DfCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    this.onTap,
    this.semanticLabel,
    this.variant = DfCardVariant.grouped,
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
    final brightness = theme.brightness;

    final Widget card = switch (variant) {
      DfCardVariant.brand => _BrandCard(padding: padding, child: child),
      DfCardVariant.hero => _HeroCard(
          brightness: brightness,
          padding: padding,
          child: child,
        ),
      DfCardVariant.glass => _GlassCard(
          isDark: isDark,
          padding: padding,
          child: child,
        ),
      DfCardVariant.elevated => _ElevatedCard(
          brightness: brightness,
          padding: padding,
          child: child,
        ),
      DfCardVariant.grouped => _GroupedCard(
          brightness: brightness,
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
              borderRadius: AppRadius.grouped,
              splashColor: AppColors.brandBlue.withValues(alpha: 0.08),
              child: card,
            ),
          );

    if (semanticLabel == null) return content;
    return Semantics(label: semanticLabel, button: onTap != null, child: content);
  }
}

class _GroupedCard extends StatelessWidget {
  const _GroupedCard({
    required this.brightness,
    required this.padding,
    required this.child,
  });

  final Brightness brightness;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.secondaryGrouped(brightness),
        borderRadius: AppRadius.grouped,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _ElevatedCard extends StatelessWidget {
  const _ElevatedCard({
    required this.brightness,
    required this.padding,
    required this.child,
  });

  final Brightness brightness;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.surfaceCardTopLight(brightness),
        borderRadius: AppRadius.grouped,
        border: Border.all(
          color: brightness == Brightness.dark
              ? AppColors.glassBorder
              : AppColors.lightBorder.withValues(alpha: 0.6),
        ),
        boxShadow: AppElevation.surfaceCard(brightness),
      ),
      child: Padding(padding: padding, child: child),
    );
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
      borderRadius: AppRadius.grouped,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: AppRadius.grouped,
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

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.brightness,
    required this.padding,
    required this.child,
  });

  final Brightness brightness;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.grouped,
        gradient: AppGradients.heroCardAccent(brightness),
        border: Border.all(
          color: AppColors.brandBlue.withValues(alpha: 0.15),
        ),
        boxShadow: AppElevation.surfaceCard(brightness),
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
        gradient: AppGradients.heroWealth,
        boxShadow: AppElevation.brandGlow(Theme.of(context).brightness),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            top: -24,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}
