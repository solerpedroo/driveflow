import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/df_haptics.dart';

/// Controle segmentado premium — substitui FilterChip genérico.
class DfSegmentedControl<T> extends StatelessWidget {
  const DfSegmentedControl({
    required this.segments,
    required this.selected,
    required this.onChanged,
    required this.labelBuilder,
    super.key,
  });

  final List<T> segments;
  final T selected;
  final ValueChanged<T> onChanged;
  final String Function(T) labelBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.mutedSurface(theme).withValues(alpha: 0.65),
        borderRadius: AppRadius.lgAll,
        border: Border.all(
          color: isDark ? AppColors.glassBorder : AppColors.glassBorderLight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final segment in segments) ...[
              _Segment(
                label: labelBuilder(segment),
                selected: segment == selected,
                onTap: () {
                  if (segment != selected) {
                    DfHaptics.selection();
                    onChanged(segment);
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: DriveFlowMotion.fast,
        curve: DriveFlowMotion.spring,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.skyBlue.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: AppRadius.mdAll,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.skyBlue.withValues(alpha: 0.22),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: selected
                ? AppColors.skyBlue
                : AppColors.secondaryLabel(theme),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
