import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../integrations/domain/entities/platform_efficiency_snapshot.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Barras horizontais — R$/corrida e R$/km por app.
class PlatformEfficiencyChart extends StatelessWidget {
  const PlatformEfficiencyChart({required this.snapshots, super.key});

  final List<PlatformEfficiencySnapshot> snapshots;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (snapshots.isEmpty) {
      return DfCard(
        child: Text('Sem dados de eficiência.', style: theme.textTheme.bodyMedium),
      );
    }

    final maxPerRide =
        snapshots.map((s) => s.avgPerRide).reduce((a, b) => a > b ? a : b);

    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Eficiência por app',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final snap in snapshots) ...[
            Row(
              children: [
                SizedBox(
                  width: 56,
                  child: Text(
                    snap.platform.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: maxPerRide > 0
                          ? (snap.avgPerRide / maxPerRide).clamp(0.05, 1.0)
                          : 0,
                      minHeight: 8,
                      backgroundColor: AppColors.skyBlue.withValues(alpha: 0.12),
                      color: AppColors.skyBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  CurrencyFormatter.format(snap.avgPerRide),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.profitGreen,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 56, bottom: AppSpacing.sm),
              child: Text(
                '${CurrencyFormatter.format(snap.avgPerKm)}/km · '
                '${snap.avgDistanceKm.toStringAsFixed(1)} km médio · '
                'gorjeta ${CurrencyFormatter.format(snap.avgTipPerRide)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.secondaryLabel(theme),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
