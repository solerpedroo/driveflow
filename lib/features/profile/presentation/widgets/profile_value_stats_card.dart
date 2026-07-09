import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/domain/models/period_summary.dart';
import '../../../../shared/widgets/design_system/df_card.dart';

/// Métricas de valor acumulado — storytelling com números reais do motorista.
class ProfileValueStatsCard extends StatelessWidget {
  const ProfileValueStatsCard({
    required this.month,
    required this.totalRides,
    super.key,
  });

  final PeriodSummary month;
  final int totalRides;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = month.revenue > 0 || totalRides > 0;

    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seu impacto com DriveFlow',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (!hasData)
            Text(
              'Registre corridas e veja aqui quanto você já lucrou com clareza.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryLabel(theme),
              ),
            )
          else ...[
            _StatRow(
              label: 'Lucro registrado no mês',
              value: CurrencyFormatter.formatSigned(month.profit),
              color: month.profit >= 0
                  ? AppColors.profitGreen
                  : AppColors.expenseCoral,
            ),
            const SizedBox(height: AppSpacing.sm),
            _StatRow(
              label: 'Corridas no mês',
              value: '$totalRides',
              color: AppColors.skyBlue,
            ),
            if (month.profitPerHour != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _StatRow(
                label: 'Lucro médio por hora',
                value: CurrencyFormatter.format(month.profitPerHour!),
                color: AppColors.skyBlue,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryLabel(theme),
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
