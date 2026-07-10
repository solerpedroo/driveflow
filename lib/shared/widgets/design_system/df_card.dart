import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

enum DfCardVariant { grouped, elevated, glass, hero, brand }

/// Cartão estilo iOS — grouped inset, sem sombra pesada.
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

    final Widget card = switch (variant) {
      DfCardVariant.brand => _BrandCard(padding: padding, child: child),
      DfCardVariant.hero => _HeroCard(
          isDark: isDark,
          padding: padding,
          child: child,
        ),
      DfCardVariant.glass => _GlassCard(
          isDark: isDark,
          padding: padding,
          child: child,
        ),
      DfCardVariant.elevated || DfCardVariant.grouped => _GroupedCard(
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
              borderRadius: AppRadius.grouped,
              splashColor: AppColors.systemBlue.withValues(alpha: 0.08),
              child: card,
            ),
          );

    if (semanticLabel == null) return content;
    return Semantics(label: semanticLabel, button: onTap != null, child: content);
  }
}

class _GroupedCard extends StatelessWidget {
  const _GroupedCard({
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
        color: AppColors.secondaryGrouped(brightness),
        borderRadius: AppRadius.grouped,
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.secondaryGrouped(
          isDark ? Brightness.dark : Brightness.light,
        ),
        borderRadius: AppRadius.grouped,
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
        borderRadius: AppRadius.grouped,
        color: AppColors.secondaryGrouped(
          isDark ? Brightness.dark : Brightness.light,
        ),
        border: Border.all(
          color: AppColors.systemBlue.withValues(alpha: 0.12),
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
        color: AppColors.systemBlue,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
