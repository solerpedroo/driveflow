import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/df_haptics.dart';

/// Segmented control estilo Cupertino — fundo muted, pill branco no selecionado.
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
        color: AppColors.mutedSurface(theme),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Row(
          children: [
            for (final segment in segments)
              Expanded(
                child: _Segment(
                  label: labelBuilder(segment),
                  selected: segment == selected,
                  isDark: isDark,
                  onTap: () {
                    if (segment != selected) {
                      DfHaptics.selection();
                      onChanged(segment);
                    }
                  },
                ),
              ),
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
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: DriveFlowMotion.fast,
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.secondaryGrouped(
                  isDark ? Brightness.dark : Brightness.light,
                )
              : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.iosFootnote(
            isDark ? Brightness.dark : Brightness.light,
          ).copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected
                ? AppColors.brandBlue
                : AppColors.secondaryLabel(Theme.of(context)),
          ),
        ),
      ),
    );
  }
}
