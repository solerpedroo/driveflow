import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/shift_session_summary.dart';

/// Caixa líquido ao vivo — ganhos, despesas e líquido do turno.
class ShiftNetCashCard extends StatelessWidget {
  const ShiftNetCashCard({
    required this.summary,
    required this.hideValue,
    super.key,
  });

  final ShiftSessionSummary summary;
  final bool hideValue;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final theme = Theme.of(context);
    final netPositive = summary.netCash >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _Stat(
                label: 'Ganhos',
                value: hideValue
                    ? '•••'
                    : CurrencyFormatter.format(summary.revenue),
                brightness: brightness,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _Stat(
                label: 'Despesas',
                value: hideValue
                    ? '•••'
                    : CurrencyFormatter.format(summary.expenses),
                brightness: brightness,
                valueColor: summary.expenses > 0
                    ? AppColors.expenseCoral
                    : null,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _Stat(
                label: 'Líquido',
                value: hideValue
                    ? '•••'
                    : CurrencyFormatter.formatSigned(summary.netCash),
                brightness: brightness,
                valueColor: netPositive
                    ? AppColors.profitGreen
                    : AppColors.expenseCoral,
              ),
            ),
          ],
        ),
        if (summary.netPerHour != null && summary.hasNetCashTracking) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            hideValue
                ? '•••/h líquido'
                : '${CurrencyFormatter.formatSigned(summary.netPerHour!)}/h líquido',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.brandBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        Text(
          hideValue
              ? '••• corridas'
              : '${summary.rides} corridas'
              '${summary.revenuePerHour == null ? '' : ' · ${CurrencyFormatter.format(summary.revenuePerHour!)}/h bruto'}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.secondaryLabel(theme),
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.brightness,
    this.valueColor,
  });

  final String label;
  final String value;
  final Brightness brightness;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.iosFootnote(brightness)),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.iosHeadline(brightness).copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
