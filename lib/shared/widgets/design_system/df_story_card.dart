import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/df_haptics.dart';
import 'df_card.dart';

/// Card narrativo com métrica de valor — storytelling de produto.
class DfStoryCard extends StatelessWidget {
  const DfStoryCard({
    required this.label,
    required this.value,
    required this.narrative,
    required this.icon,
    required this.accent,
    super.key,
    this.onTap,
  });

  final String label;
  final String value;
  final String narrative;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DfCard(
      variant: DfCardVariant.elevated,
      onTap: onTap == null
          ? null
          : () {
              DfHaptics.light();
              onTap!();
            },
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SizedBox(
        width: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: AppRadius.mdAll,
              ),
              child: Icon(icon, color: accent, size: 22),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.secondaryLabel(theme),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              narrative,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryLabel(theme),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
