import 'package:flutter/material.dart';

import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Mix de faturamento por app nos turnos do período.
class ShiftPlatformMixChart extends StatelessWidget {
  const ShiftPlatformMixChart({
    required this.platformRevenue,
    super.key,
  });

  final Map<RidePlatform, double> platformRevenue;

  static const _colors = [
    AppColors.deepNavy,
    AppColors.warningAmber,
    AppColors.profitGreen,
    AppColors.skyBlue,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = platformRevenue.entries
        .where((entry) => entry.value > 0)
        .toList(growable: false)
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) return const SizedBox.shrink();

    final total = entries.fold<double>(0, (sum, entry) => sum + entry.value);

    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mix por app',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < entries.length; i++) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    entries[i].key.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  CurrencyFormatter.format(entries[i].value),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: total > 0 ? entries[i].value / total : 0,
                minHeight: 8,
                backgroundColor:
                    AppColors.secondaryLabel(theme).withValues(alpha: 0.15),
                color: _colors[i % _colors.length],
              ),
            ),
            if (i < entries.length - 1) const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}
