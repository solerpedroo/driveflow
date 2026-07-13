import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../domain/entities/shift_daily_point.dart';

/// Barras de faturamento diário dos turnos.
class ShiftRevenueTrendChart extends StatelessWidget {
  const ShiftRevenueTrendChart({
    required this.points,
    required this.windowLabel,
    super.key,
  });

  final List<ShiftDailyPoint> points;
  final String windowLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = points.where((point) => point.revenue > 0).toList();

    if (active.isEmpty) {
      return DfCard(
        child: Text(
          'Sem turnos no período.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    final maxY = active.map((p) => p.revenue).reduce((a, b) => a > b ? a : b);
    final total = points.fold<double>(0, (sum, p) => sum + p.revenue);
    final showEvery = points.length > 14 ? (points.length / 5).floor() : 1;

    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Faturamento por dia',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$windowLabel · ${CurrencyFormatter.format(total)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryLabel(theme),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxY * 1.25,
                barGroups: [
                  for (var i = 0; i < points.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: points[i].revenue,
                          color: points[i].revenue > 0
                              ? AppColors.skyBlue
                              : AppColors.secondaryLabel(theme)
                                  .withValues(alpha: 0.2),
                          width: points.length > 14 ? 10 : 18,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= points.length) {
                          return const SizedBox.shrink();
                        }
                        if (index % showEvery != 0 &&
                            index != points.length - 1) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            points[index].weekdayLabel,
                            style: theme.textTheme.labelSmall,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
