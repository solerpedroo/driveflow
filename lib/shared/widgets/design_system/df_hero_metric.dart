import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Métrica hero com tipografia editorial — padrão FitCal daily summary.
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: [
        Text(
          value,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -1.2,
            color: valueColor ?? theme.colorScheme.onSurface,
            height: 1.0,
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
