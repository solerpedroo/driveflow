import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../../../shared/domain/models/daily_profit_point.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Gráfico premium — barras com gradiente, animação e tooltip tátil.
class WeeklyProfitChart extends StatefulWidget {
  const WeeklyProfitChart({
    required this.points,
    super.key,
  });

  final List<DailyProfitPoint> points;

  @override
  State<WeeklyProfitChart> createState() => _WeeklyProfitChartState();
}

class _WeeklyProfitChartState extends State<WeeklyProfitChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: DriveFlowMotion.chart,
    )..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points = widget.points;
    final maxProfit = points.fold<double>(
      0,
      (max, point) => point.profit > max ? point.profit : max,
    );
    final chartMax = maxProfit <= 0 ? 100.0 : maxProfit * 1.25;
    final total = points.fold<double>(0, (s, p) => s + p.profit);
    final todayIndex = points.length - 1;

    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Lucro semanal',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                CurrencyFormatter.formatSigned(total),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: total >= 0
                      ? AppColors.profitGreen
                      : AppColors.expenseCoral,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              return SizedBox(
                height: 190,
                child: BarChart(
                  BarChartData(
                    maxY: chartMax,
                    minY: 0,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchCallback: (event, response) {
                        if (!event.isInterestedForInteractions) {
                          setState(() => _touchedIndex = null);
                          return;
                        }
                        final index = response?.spot?.touchedBarGroupIndex;
                        if (index != null && index != _touchedIndex) {
                          DfHaptics.light();
                        }
                        setState(() => _touchedIndex = index);
                      },
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) =>
                            AppColors.deepNavy.withValues(alpha: 0.92),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final p = points[group.x.toInt()];
                          return BarTooltipItem(
                            '${p.weekdayLabel}\n${CurrencyFormatter.formatSigned(p.profit)}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: chartMax / 4,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: AppColors.secondaryLabel(theme)
                            .withValues(alpha: 0.12),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= points.length) {
                              return const SizedBox.shrink();
                            }
                            final isToday = index == todayIndex;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                points[index].weekdayLabel,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isToday
                                      ? AppColors.skyBlue
                                      : AppColors.secondaryLabel(theme),
                                  fontWeight:
                                      isToday ? FontWeight.w700 : FontWeight.w400,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: [
                      for (var i = 0; i < points.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: points[i].profit.clamp(0, chartMax) *
                                  _anim.value,
                              width: _touchedIndex == i ? 20 : 16,
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: points[i].profit >= 0
                                    ? [
                                        AppColors.profitGreen
                                            .withValues(alpha: 0.55),
                                        AppColors.profitGreen,
                                      ]
                                    : [
                                        AppColors.expenseCoral
                                            .withValues(alpha: 0.55),
                                        AppColors.expenseCoral,
                                      ],
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  duration: DriveFlowMotion.fast,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
