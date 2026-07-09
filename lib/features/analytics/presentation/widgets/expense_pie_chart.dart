import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../domain/entities/category_breakdown_slice.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Gráfico de pizza premium — animação de entrada e toque tátil.
class ExpensePieChart extends StatefulWidget {
  const ExpensePieChart({
    required this.slices,
    super.key,
  });

  final List<CategoryBreakdownSlice> slices;

  static const _palette = [
    AppColors.expenseCoral,
    AppColors.warningAmber,
    AppColors.infoBlue,
    AppColors.skyBlue,
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFFF97316),
    Color(0xFF64748B),
    Color(0xFF84CC16),
  ];

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart>
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
    final slices = widget.slices;

    if (slices.isEmpty) {
      return DfCard(
        child: Text(
          'Nenhuma despesa no período.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    final legend = slices.take(5).map((s) => s.category.label).join(', ');

    return Semantics(
      label: 'Gráfico de despesas por categoria: $legend',
      child: RepaintBoundary(
        child: DfCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Despesas por categoria',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AnimatedBuilder(
                animation: _anim,
                builder: (context, _) {
                  return SizedBox(
                    height: 200,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 36,
                              pieTouchData: PieTouchData(
                                touchCallback: (event, response) {
                                  if (!event.isInterestedForInteractions) {
                                    setState(() => _touchedIndex = null);
                                    return;
                                  }
                                  final index = response?.touchedSection?.touchedSectionIndex;
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
                                    color: ExpensePieChart._palette[
                                        i % ExpensePieChart._palette.length],
                                    radius: _touchedIndex == i ? 62 : 56,
                                    title:
                                        '${(slices[i].share * 100).toStringAsFixed(0)}%',
                                    titleStyle:
                                        theme.textTheme.labelSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                            duration: DriveFlowMotion.fast,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var i = 0; i < slices.length && i < 5; i++)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.xs,
                                  ),
                                  child: Row(
                                    children: [
                                      AnimatedContainer(
                                        duration: DriveFlowMotion.fast,
                                        width: _touchedIndex == i ? 12 : 10,
                                        height: _touchedIndex == i ? 12 : 10,
                                        decoration: BoxDecoration(
                                          color: ExpensePieChart._palette[
                                              i % ExpensePieChart._palette.length],
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Text(
                                          slices[i].category.label,
                                          style:
                                              theme.textTheme.bodySmall?.copyWith(
                                            fontWeight: _touchedIndex == i
                                                ? FontWeight.w700
                                                : FontWeight.w400,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        CurrencyFormatter.format(slices[i].amount),
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          fontWeight: _touchedIndex == i
                                              ? FontWeight.w700
                                              : FontWeight.w400,
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
        ),
      ),
    );
  }
}
