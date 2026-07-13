import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_subpage_scaffold.dart';
import '../../../../shared/widgets/platform_brand_icon.dart';
import '../providers/shift_history_providers.dart';
import '../widgets/shift_adherence_badge.dart';
import '../widgets/shift_timer_widget.dart';

/// Retrospectiva detalhada de um turno encerrado.
class ShiftRetrospectiveScreen extends ConsumerWidget {
  const ShiftRetrospectiveScreen({required this.entryId, super.key});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final retrospective = ref.watch(shiftRetrospectiveProvider(entryId));

    if (retrospective == null) {
      return const DfSubpageScaffold(
        title: 'Retrospectiva',
        children: [
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    final entry = retrospective.entry;
    final theme = Theme.of(context);

    return DfSubpageScaffold(
      title: 'Retrospectiva',
      children: [
        DfCard(
          variant: DfCardVariant.hero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                CurrencyFormatter.format(entry.revenue),
                style: AppTypography.iosLargeTitle(theme.brightness).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${ShiftTimerWidget.format(entry.elapsed)} · ${entry.rides} corridas',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryLabel(theme),
                ),
              ),
              if (entry.revenuePerHour != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${CurrencyFormatter.format(entry.revenuePerHour!)}/h',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.brandBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        DfCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Insight',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (entry.totalPlanBlocks > 0)
                    ShiftAdherenceBadge(score: entry.adherenceScore),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                retrospective.insight,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
              ),
            ],
          ),
        ),
        if (retrospective.platformBreakdown.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          DfCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mix por app',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                for (final slice in retrospective.platformBreakdown)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        if (PlatformBrandIcon.hasBrandAsset(slice.platform))
                          PlatformBrandIcon(
                            platform: slice.platform,
                            size: 24,
                            borderRadius: 6,
                          ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(child: Text(slice.platform.label)),
                        Text(
                          CurrencyFormatter.format(slice.revenue),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '${(slice.share * 100).round()}%',
                          style: AppTypography.iosFootnote(theme.brightness),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
        if (retrospective.blockOutcomes.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          DfCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plano vs realizado',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                for (final outcome in retrospective.blockOutcomes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          outcome.matched
                              ? Icons.check_circle_rounded
                              : Icons.swap_horiz_rounded,
                          color: outcome.matched
                              ? AppColors.profitGreen
                              : AppColors.warningAmber,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${outcome.block.timeRange} · '
                                '${outcome.block.platform.label}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                outcome.actualPlatform == null
                                    ? 'Sem ganhos no bloco'
                                    : 'Real: ${outcome.actualPlatform!.label} · '
                                        '${CurrencyFormatter.format(outcome.revenue)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.secondaryLabel(theme),
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
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Voltar ao histórico'),
        ),
      ],
    );
  }
}
