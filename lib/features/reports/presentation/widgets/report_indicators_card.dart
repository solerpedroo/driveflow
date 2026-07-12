import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_elevation.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../domain/entities/report_snapshot.dart';

/// Indicadores do relatório — módulo elevado no padrão Início.
class ReportIndicatorsCard extends StatelessWidget {
  const ReportIndicatorsCard({
    required this.report,
    this.hideValue = false,
    super.key,
  });

  final ReportSnapshot report;
  final bool hideValue;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final summary = report.summary;
    final profitColor =
        summary.profit >= 0 ? AppColors.profitGreen : AppColors.expenseCoral;

    final rows = <_IndicatorData>[
      _IndicatorData(
        label: 'Receita',
        value: maskCurrency(
          CurrencyFormatter.format(summary.revenue),
          hidden: hideValue,
        ),
      ),
      _IndicatorData(
        label: 'Despesas',
        value: maskCurrency(
          CurrencyFormatter.format(summary.expenses),
          hidden: hideValue,
        ),
      ),
      _IndicatorData(
        label: 'Lucro',
        value: maskCurrency(
          CurrencyFormatter.formatSigned(summary.profit),
          hidden: hideValue,
        ),
        valueColor: hideValue ? null : profitColor,
        emphasized: true,
      ),
      _IndicatorData(
        label: 'Horas',
        value: maskPlain(
          DurationFormatter.formatWorkedHours(summary.workedHours),
          hidden: hideValue,
        ),
      ),
      _IndicatorData(
        label: 'Corridas',
        value: maskPlain('${summary.rides}', hidden: hideValue),
      ),
      _IndicatorData(
        label: 'Km estimados',
        value: summary.kmDriven > 0
            ? maskPlain(summary.kmDriven.toStringAsFixed(0), hidden: hideValue)
            : '—',
      ),
      _IndicatorData(
        label: 'Combustível',
        value: maskCurrency(
          CurrencyFormatter.format(summary.fuelExpense),
          hidden: hideValue,
        ),
      ),
      if (summary.profitPerHour != null)
        _IndicatorData(
          label: 'Lucro / hora',
          value: maskCurrency(
            CurrencyFormatter.format(summary.profitPerHour!),
            hidden: hideValue,
          ),
          emphasized: true,
        ),
      if (summary.profitPerKm != null)
        _IndicatorData(
          label: 'Lucro / km',
          value: maskCurrency(
            CurrencyFormatter.format(summary.profitPerKm!),
            hidden: hideValue,
          ),
        ),
    ];

    return DfCard(
      variant: DfCardVariant.elevated,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Indicadores',
            style: AppTypography.labelCaps(brightness),
          ),
          const SizedBox(height: 4),
          Text(
            report.periodLabel,
            style: AppTypography.iosFootnote(brightness),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 0.5,
                color: AppElevation.hairline(brightness).color,
              ),
            _IndicatorRow(data: rows[i]),
          ],
        ],
      ),
    );
  }
}

class _IndicatorData {
  const _IndicatorData({
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasized;
}

class _IndicatorRow extends StatelessWidget {
  const _IndicatorRow({required this.data});

  final _IndicatorData data;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              data.label,
              style: AppTypography.iosBody(brightness).copyWith(
                color: AppColors.secondaryLabel(Theme.of(context)),
                fontSize: 15,
              ),
            ),
          ),
          Text(
            data.value,
            style: AppTypography.iosHeadline(brightness).copyWith(
              fontSize: data.emphasized ? 17 : 15,
              fontWeight: data.emphasized ? FontWeight.w700 : FontWeight.w600,
              color: data.valueColor ??
                  (data.emphasized ? AppColors.brandBlue : null),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
