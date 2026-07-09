import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_elevation.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

/// Cartão glass do Design System v2.
class DfCard extends StatelessWidget {
  const DfCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor =
        isDark ? AppColors.glassBorder : AppColors.glassBorderLight;
    final fill = isDark
        ? AppColors.slate.withValues(alpha: 0.45)
        : Colors.white.withValues(alpha: 0.72);

    final card = ClipRRect(
      borderRadius: AppRadius.xlAll,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: AppRadius.xlAll,
            border: Border.all(color: borderColor),
            boxShadow: AppElevation.glassShadow(theme.brightness),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

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
