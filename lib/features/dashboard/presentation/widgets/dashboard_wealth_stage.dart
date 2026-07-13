import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_elevation.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/df_haptics.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../../../shared/domain/models/period_summary.dart';
import '../../../goals/domain/services/goal_progress_calculator.dart';

/// Card de lucro — mesmo DNA do preview do login (Wallet).
class DashboardWealthStage extends StatelessWidget {
  const DashboardWealthStage({
    required this.month,
    required this.today,
    required this.goal,
    required this.hideValue,
    required this.onToggleVisibility,
    this.storySubtitle,
    super.key,
  });

  final PeriodSummary month;
  final PeriodSummary today;
  final GoalProgress goal;
  final bool hideValue;
  final VoidCallback onToggleVisibility;
  final String? storySubtitle;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final monthDisplay = maskCurrency(
      CurrencyFormatter.formatSigned(month.profit),
      hidden: hideValue,
    );
    final badge = goal.hasTarget
        ? 'Meta ${maskPlain(goal.progressLabel, hidden: hideValue)}'
        : '${today.rides} corridas';

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.xlAll,
        gradient: AppGradients.heroWealth,
        boxShadow: [
          BoxShadow(
            color: AppColors.brandBlue.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
          ...AppElevation.heroDepth(brightness),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.xlAll,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Lucro do mês',
                      style: AppTypography.labelCaps(brightness).copyWith(
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      DfHaptics.light();
                      onToggleVisibility();
                    },
                    tooltip: hideValue ? 'Mostrar valores' : 'Ocultar valores',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    icon: Icon(
                      hideValue
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 22,
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.16),
                      ),
                    ),
                    child: Text(
                      hideValue ? '•••' : badge,
                      style: AppTypography.iosFootnote(brightness).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (storySubtitle != null && storySubtitle!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  storySubtitle!,
                  style: AppTypography.iosFootnote(brightness).copyWith(
                    color: Colors.white.withValues(alpha: 0.72),
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Text(
                monthDisplay,
                style: AppTypography.metric(
                  brightness,
                  fontSize: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Divider(
                height: 1,
                thickness: 0.5,
                color: Colors.white.withValues(alpha: 0.16),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _Stat(
                      label: 'Ganhos',
                      value: maskCurrency(
                        CurrencyFormatter.format(month.revenue),
                        hidden: hideValue,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _Stat(
                      label: 'Despesas',
                      value: maskCurrency(
                        CurrencyFormatter.format(month.expenses),
                        hidden: hideValue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                hideValue
                    ? 'Hoje · ••••••'
                    : 'Hoje · ${CurrencyFormatter.formatSigned(today.profit)}',
                style: AppTypography.iosFootnote(brightness).copyWith(
                  color: Colors.white.withValues(alpha: 0.70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

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
