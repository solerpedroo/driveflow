import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../../integrations/domain/services/platform_analytics_breakdown.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Donut — mix de receita de hoje por app.
class PlatformRevenueDonutChart extends StatefulWidget {
  const PlatformRevenueDonutChart({required this.slices, super.key});

  final List<PlatformRevenueSlice> slices;

  static const _palette = [
    AppColors.deepNavy,
    AppColors.warningAmber,
    AppColors.profitGreen,
  ];

  @override
  State<PlatformRevenueDonutChart> createState() =>
      _PlatformRevenueDonutChartState();
}

class _PlatformRevenueDonutChartState extends State<PlatformRevenueDonutChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: DriveFlowMotion.chart)
      ..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final slices = widget.slices;

    if (slices.isEmpty) return const SizedBox.shrink();

    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mix de hoje',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              return SizedBox(
                height: 140,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 32,
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              if (!event.isInterestedForInteractions) {
                                setState(() => _touchedIndex = null);
                                return;
                              }
                              final index =
                                  response?.touchedSection?.touchedSectionIndex;
                              if (index != null && index != _touchedIndex) {
                                DfHaptics.light();
                              }
                              setState(() => _touchedIndex = index);
                            },
                          ),
                          sections: [
                            for (var i = 0; i < slices.length; i++)
                              PieChartSectionData(
                                value: slices[i].amount * _anim.value,
                                color: PlatformRevenueDonutChart._palette[
                                    i % PlatformRevenueDonutChart._palette.length],
                                radius: _touchedIndex == i ? 48 : 42,
                                title:
                                    '${slices[i].sharePercent.toStringAsFixed(0)}%',
                                titleStyle: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < slices.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: PlatformRevenueDonutChart._palette[
                                          i % PlatformRevenueDonutChart._palette.length],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      slices[i].platform.label,
                                      style: theme.textTheme.labelSmall,
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(slices[i].amount),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
