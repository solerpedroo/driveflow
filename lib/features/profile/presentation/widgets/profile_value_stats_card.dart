import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../../../shared/domain/models/period_summary.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_hero_wealth_card.dart';

/// Hero de impacto do motorista — DNA Início / Ganhos.
class ProfileValueStatsCard extends StatelessWidget {
  const ProfileValueStatsCard({
    required this.month,
    required this.totalRides,
    required this.hideValue,
    required this.onToggleVisibility,
    super.key,
  });

  final PeriodSummary month;
  final int totalRides;
  final bool hideValue;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final hasData = month.revenue > 0 || totalRides > 0;

    if (!hasData) {
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
              'Seu impacto',
              style: AppTypography.labelCaps(brightness),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Registre corridas e veja aqui quanto você já lucrou com clareza.',
              style: AppTypography.iosBody(brightness).copyWith(
                color: AppColors.secondaryLabel(theme),
                height: 1.4,
                fontSize: 15,
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
      onToggleVisibility: onToggleVisibility,
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
    final brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.iosFootnote(brightness).copyWith(
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.iosHeadline(brightness).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
