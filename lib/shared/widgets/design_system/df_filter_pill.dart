import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/df_haptics.dart';

/// Pill de filtro premium — uso em listas horizontais (plataforma, tags).
class DfFilterPill extends StatelessWidget {
  const DfFilterPill({
    required this.label,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: () {
          if (!selected) DfHaptics.selection();
          onSelected();
        },
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
                : AppColors.mutedSurface(theme).withValues(alpha: 0.65),
            borderRadius: AppRadius.lgAll,
            border: Border.all(
              color: selected
                  ? AppColors.skyBlue.withValues(alpha: 0.35)
                  : theme.dividerColor.withValues(alpha: 0.35),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.skyBlue.withValues(alpha: 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
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
      ),
    );
  }
}
