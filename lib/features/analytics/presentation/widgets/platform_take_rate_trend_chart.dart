import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../integrations/domain/entities/platform_take_rate_point.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Linha de take rate semanal por app.
class PlatformTakeRateTrendChart extends StatelessWidget {
  const PlatformTakeRateTrendChart({required this.points, super.key});

  final List<PlatformTakeRatePoint> points;

  static const _colors = {
    RidePlatform.uber: AppColors.deepNavy,
    RidePlatform.ninetyNine: AppColors.warningAmber,
    RidePlatform.inDrive: AppColors.profitGreen,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (points.isEmpty) {
      return DfCard(
        child: Text('Sem histórico de taxas.', style: theme.textTheme.bodyMedium),
      );
    }

    final maxY = points
        .map((p) => p.takeRatePercent)
        .reduce((a, b) => a > b ? a : b);

    final weekStarts = points
        .map((p) => p.weekStart)
        .toSet()
        .toList()
      ..sort();

    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Take rate semanal',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                maxY: maxY * 1.2,
                minY: 0,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  for (final platform in PlatformTakeRateTrendChart._colors.keys)
                    if (points.any((p) => p.platform == platform))
                      LineChartBarData(
                        spots: [
                          for (var i = 0; i < weekStarts.length; i++)
                            FlSpot(
                              i.toDouble(),
                              points
                                  .where(
                                    (p) =>
                                        p.platform == platform &&
                                        p.weekStart == weekStarts[i],
                                  )
                                  .map((p) => p.takeRatePercent)
                                  .firstOrNull ?? 0,
                            ),
                        ],
                        isCurved: true,
                        color: PlatformTakeRateTrendChart._colors[platform],
                        barWidth: 2,
                        dotData: const FlDotData(show: true),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
