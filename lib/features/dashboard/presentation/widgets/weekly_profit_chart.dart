import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../../../shared/domain/models/daily_profit_point.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Módulo semanal premium — métrica dominante + barras brand.
class WeeklyProfitChart extends StatefulWidget {
  const WeeklyProfitChart({
    required this.points,
    this.hideValue = false,
    super.key,
  });

  final List<DailyProfitPoint> points;
  final bool hideValue;

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
    final brightness = theme.brightness;
    final points = widget.points;
    final maxProfit = points.fold<double>(
      0,
      (max, point) => point.profit > max ? point.profit : max,
    );
    final chartMax = maxProfit <= 0 ? 100.0 : maxProfit * 1.25;
    final total = points.fold<double>(0, (s, p) => s + p.profit);
    final todayIndex = points.length - 1;
    final totalColor =
        total >= 0 ? AppColors.profitGreen : AppColors.expenseCoral;

    return DfCard(
      variant: DfCardVariant.elevated,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lucro semanal',
            style: AppTypography.labelCaps(brightness),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            maskCurrency(
              CurrencyFormatter.formatSigned(total),
              hidden: widget.hideValue,
            ),
            style: AppTypography.metric(
              brightness,
              fontSize: 28,
              color: widget.hideValue ? theme.colorScheme.onSurface : totalColor,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              return SizedBox(
                height: 168,
                child: BarChart(
                  BarChartData(
                    maxY: chartMax,
                    minY: 0,
                    alignment: BarChartAlignment.spaceAround,
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
                            AppColors.deepNavy.withValues(alpha: 0.94),
                        tooltipRoundedRadius: 10,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final p = points[group.x.toInt()];
                          final value = maskCurrency(
                            CurrencyFormatter.formatSigned(p.profit),
                            hidden: widget.hideValue,
                          );
                          return BarTooltipItem(
                            '${p.weekdayLabel}\n$value',
                            AppTypography.iosCaption(brightness).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
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
                            .withValues(alpha: 0.08),
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
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= points.length) {
                              return const SizedBox.shrink();
                            }
                            final isToday = index == todayIndex;
                            final isTouched = index == _touchedIndex;
                            return Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                points[index].weekdayLabel,
                                style:
                                    AppTypography.iosCaption(brightness).copyWith(
                                  color: isToday || isTouched
                                      ? AppColors.brandBlue
                                      : AppColors.secondaryLabel(theme),
                                  fontWeight: isToday || isTouched
                                      ? FontWeight.w700
                                      : FontWeight.w500,
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
                              toY: (points[i].profit <= 0
                                      ? chartMax * 0.03
                                      : points[i].profit.clamp(0, chartMax)) *
                                  _anim.value,
                              width: _touchedIndex == i ? 18 : 14,
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: _barColors(
                                  profit: points[i].profit,
                                  isToday: i == todayIndex,
                                  isTouched: i == _touchedIndex,
                                ),
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(7),
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

  List<Color> _barColors({
    required double profit,
    required bool isToday,
    required bool isTouched,
  }) {
    if (profit < 0) {
      return [
        AppColors.expenseCoral.withValues(alpha: 0.45),
        AppColors.expenseCoral,
      ];
    }
    if (profit <= 0) {
      return [
        AppColors.brandBlue.withValues(alpha: 0.08),
        AppColors.brandBlue.withValues(alpha: 0.16),
      ];
    }
    if (isToday || isTouched) {
      return [
        AppColors.brandBlue.withValues(alpha: 0.55),
        AppColors.brandBlue,
      ];
    }
    return [
      AppColors.brandBlue.withValues(alpha: 0.28),
      AppColors.brandBlue.withValues(alpha: 0.72),
    ];
  }
}
