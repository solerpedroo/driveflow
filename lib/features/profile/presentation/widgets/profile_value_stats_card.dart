import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../../../shared/domain/models/period_summary.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_hero_wealth_card.dart';

/// Hero de impacto do motorista — mesmo padrão financeiro das abas Ganhos/Dashboard.
class ProfileValueStatsCard extends StatelessWidget {
  const ProfileValueStatsCard({
    required this.month,
    required this.totalRides,
    required this.hideValue,
    super.key,
  });

  final PeriodSummary month;
  final int totalRides;
  final bool hideValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = month.revenue > 0 || totalRides > 0;

    if (!hasData) {
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
            Text(
              'Registre corridas e veja aqui quanto você já lucrou com clareza.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryLabel(theme),
              ),
            ),
          ],
        ),
      );
    }

    return DfHeroWealthCard(
      label: 'Lucro do mês',
      value: CurrencyFormatter.formatSigned(month.profit),
      badge: hideValue ? '•••' : '$totalRides corridas',
      hideValue: hideValue,
      footer: Row(
        children: [
          Expanded(
            child: _HeroMiniStat(
              label: 'Ganhos',
              value: maskCurrency(
                CurrencyFormatter.format(month.revenue),
                hidden: hideValue,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _HeroMiniStat(
              label: month.profitPerHour != null ? 'Por hora' : 'Corridas',
              value: month.profitPerHour != null
                  ? maskCurrency(
                      CurrencyFormatter.format(month.profitPerHour!),
                      hidden: hideValue,
                    )
                  : (hideValue ? '•••' : '$totalRides'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMiniStat extends StatelessWidget {
  const _HeroMiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.70),
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
        ),
      ],
    );
  }
}
