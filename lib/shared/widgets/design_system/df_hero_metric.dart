import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Métrica hero — tipografia Geist com tabular figures.
class DfHeroMetric extends StatelessWidget {
  const DfHeroMetric({
    required this.value,
    required this.label,
    super.key,
    this.subtitle,
    this.valueColor,
    this.alignment = CrossAxisAlignment.center,
  });

  final String value;
  final String label;
  final String? subtitle;
  final Color? valueColor;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: [
        Text(
          value,
          style: AppTypography.metric(
            brightness,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: valueColor ?? theme.colorScheme.onSurface,
          ),
          textAlign: alignment == CrossAxisAlignment.center
              ? TextAlign.center
              : TextAlign.start,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppColors.secondaryLabel(theme),
            fontWeight: FontWeight.w500,
          ),
          textAlign: alignment == CrossAxisAlignment.center
              ? TextAlign.center
              : TextAlign.start,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryLabel(theme),
            ),
          ),
        ],
      ],
    );
  }
}
