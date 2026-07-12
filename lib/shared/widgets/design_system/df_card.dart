import 'package:flutter/material.dart';

import '../../../core/theme/app_blur.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_elevation.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import 'df_glass_surface.dart';

enum DfCardVariant { grouped, elevated, glass, hero, brand }

/// Superfície tipada — grouped / elevated / glass / hero / brand.
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
        : GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: card,
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
        border: Border.fromBorderSide(AppElevation.hairline(brightness)),
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
        borderRadius: AppRadius.xlAll,
        border: Border.fromBorderSide(AppElevation.hairline(brightness)),
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
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final fill = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.55);

    return DfGlassSurface(
      borderRadius: AppRadius.xlAll,
      sigma: AppBlur.card,
      fillColor: fill,
      boxShadow: AppElevation.glassShadow(brightness),
      padding: padding,
      child: child,
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
        borderRadius: AppRadius.xlAll,
        gradient: AppGradients.heroCardAccent(brightness),
        border: Border.fromBorderSide(AppElevation.hairline(brightness)),
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
    final brightness = Theme.of(context).brightness;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.xlAll,
        gradient: AppGradients.heroWealth,
        boxShadow: AppElevation.heroDepth(brightness),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
