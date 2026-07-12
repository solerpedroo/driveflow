import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../domain/entities/category_breakdown_slice.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Donut de despesas por categoria — módulo elevado.
class ExpensePieChart extends StatefulWidget {
  const ExpensePieChart({
    required this.slices,
    this.hideValue = false,
    super.key,
  });

  final List<CategoryBreakdownSlice> slices;
  final bool hideValue;

  static const _palette = [
    AppColors.brandBlue,
    AppColors.brandBlueDark,
    AppColors.deepNavy,
    AppColors.expenseCoral,
    AppColors.warningAmber,
    Color(0xFF64748B),
    Color(0xFF14B8A6),
    Color(0xFFF97316),
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
    final brightness = theme.brightness;
    final slices = widget.slices;

    if (slices.isEmpty) {
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
              'Despesas por categoria',
              style: AppTypography.labelCaps(brightness),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Nenhuma despesa no período.',
              style: AppTypography.iosBody(brightness).copyWith(
                color: AppColors.secondaryLabel(theme),
              ),
            ),
          ],
        ),
      );
    }

    final isSingleSlice = slices.length == 1;
    final legend = slices.take(5).map((s) => s.category.label).join(', ');

    return Semantics(
      label: 'Gráfico de despesas por categoria: $legend',
      child: RepaintBoundary(
        child: DfCard(
          variant: DfCardVariant.elevated,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Despesas por categoria',
                style: AppTypography.labelCaps(brightness),
              ),
              const SizedBox(height: AppSpacing.lg),
              AnimatedBuilder(
                animation: _anim,
                builder: (context, _) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 11,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  startDegreeOffset: -90,
                                  sectionsSpace: isSingleSlice ? 0 : 2,
                                  centerSpaceRadius: 42,
                                  borderData: FlBorderData(show: false),
                                  pieTouchData: PieTouchData(
                                    touchCallback: (event, response) {
                                      if (!event.isInterestedForInteractions) {
                                        setState(() => _touchedIndex = null);
                                        return;
                                      }
                                      final index = response?.touchedSection
                                          ?.touchedSectionIndex;
                                      if (index != null &&
                                          index != _touchedIndex) {
                                        DfHaptics.light();
                                      }
                                      setState(() => _touchedIndex = index);
                                    },
                                  ),
                                  sections: [
                                    for (var i = 0; i < slices.length; i++)
                                      PieChartSectionData(
                                        value: slices[i].amount * _anim.value,
                                        color: ExpensePieChart._palette[i %
                                            ExpensePieChart._palette.length],
                                        radius: _touchedIndex == i ? 50 : 46,
                                        showTitle: !isSingleSlice &&
                                            slices[i].share >= 0.08,
                                        title:
                                            '${(slices[i].share * 100).toStringAsFixed(0)}%',
                                        titleStyle:
                                            AppTypography.iosCaption(brightness)
                                                .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        titlePositionPercentageOffset: 0.55,
                                      ),
                                  ],
                                ),
                                duration: DriveFlowMotion.fast,
                              ),
                              if (isSingleSlice)
                                Text(
                                  '100%',
                                  style: AppTypography.iosHeadline(brightness)
                                      .copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        flex: 13,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var i = 0; i < slices.length && i < 5; i++)
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: _touchedIndex == i ? 12 : 10,
                                      height: _touchedIndex == i ? 12 : 10,
                                      decoration: BoxDecoration(
                                        color: ExpensePieChart._palette[i %
                                            ExpensePieChart._palette.length],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        slices[i].category.label,
                                        style: AppTypography.iosCaption(
                                          brightness,
                                        ).copyWith(
                                          fontSize: 13,
                                          fontWeight: _touchedIndex == i
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      maskCurrency(
                                        CurrencyFormatter.format(
                                          slices[i].amount,
                                        ),
                                        hidden: widget.hideValue,
                                      ),
                                      style: AppTypography.iosCaption(brightness)
                                          .copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
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
