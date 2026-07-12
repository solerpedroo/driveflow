import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../domain/entities/platform_performance_snapshot.dart';
import '../../domain/entities/platform_shift_recommendation.dart';
import '../providers/integrations_providers.dart';
import '../providers/platform_trips_providers.dart';
import 'platform_golden_hour_card.dart';
import 'platform_score_card.dart';
import 'platform_heatmap_widget.dart';
import 'platform_shift_plan_card.dart';
import 'platform_mix_simulator_card.dart';
import 'platform_payout_calendar_card.dart';
import 'platform_region_card.dart';
import 'platform_consistency_card.dart';

/// Painel de insights cross-platform — valor agregado para o motorista.
class PlatformInsightsPanel extends ConsumerWidget {
  const PlatformInsightsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recommendation = ref.watch(platformShiftRecommendationProvider);
    final performance = ref.watch(platformPerformanceProvider);
    final missing = ref.watch(missingSyncPlatformsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        recommendation.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (rec) => rec == null
              ? const SizedBox.shrink()
              : _RecommendationCard(recommendation: rec),
        ),
        const SizedBox(height: AppSpacing.md),
        const PlatformGoldenHourCard(),
        const SizedBox(height: AppSpacing.md),
        const PlatformScoreCard(),
        const SizedBox(height: AppSpacing.md),
        const PlatformHeatmapWidget(),
        const SizedBox(height: AppSpacing.md),
        const PlatformShiftPlanCard(),
        const SizedBox(height: AppSpacing.md),
        const PlatformMixSimulatorCard(),
        const SizedBox(height: AppSpacing.md),
        const PlatformPayoutCalendarCard(),
        const SizedBox(height: AppSpacing.md),
        const PlatformRegionCard(),
        const SizedBox(height: AppSpacing.md),
        const PlatformConsistencyCard(),
        ref.watch(platformFeeAnalysisProvider).when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (fees) {
            if (fees.isEmpty) return const SizedBox.shrink();
            final best = fees.first;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: DfCard(
                child: Text(
                  'Menor taxa: ${best.platform.label} '
                  '(${best.avgTakeRatePercent.toStringAsFixed(1)}%)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryLabel(theme),
                  ),
                ),
              ),
            );
          },
        ),
        if (missing.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          DfCard(
            child: Row(
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  color: AppColors.warningAmber,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Apps conectados sem dados recentes: '
                    '${missing.map((p) => p.label).join(', ')}. '
                    'Toque em atualizar para buscar os dados mais recentes.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryLabel(theme),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        performance.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (snapshots) {
            final withData = snapshots.where((s) => s.hasData).toList();
            if (withData.isEmpty) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: DfCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comparativo R\$/hora',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...withData.map(
                      (snapshot) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _PerformanceRow(
                          snapshot: snapshot,
                          maxAvgPerHour: withData
                              .map((s) => s.avgPerHour)
                              .fold<double>(0, (a, b) => a > b ? a : b),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.recommendation});

  final PlatformShiftRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DfCard(
      variant: DfCardVariant.hero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppGradients.brand,
              borderRadius: AppRadius.mdAll,
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Melhor app agora: ${recommendation.recommended.label}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recommendation.reason,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryLabel(theme),
                    height: 1.4,
                  ),
                ),
                if (recommendation.bestHourSlot != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Turno: ${recommendation.bestHourSlot} · '
                    'Confiança ${(recommendation.confidence * 100).round()}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.brandBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceRow extends StatelessWidget {
  const _PerformanceRow({
    required this.snapshot,
    required this.maxAvgPerHour,
  });

  final PlatformPerformanceSnapshot snapshot;
  final double maxAvgPerHour;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final barWidth = maxAvgPerHour > 0
        ? snapshot.avgPerHour / maxAvgPerHour
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                snapshot.platform.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              CurrencyFormatter.format(snapshot.avgPerHour),
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.profitGreen,
              ),
            ),
            Text(
              '/h',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.secondaryLabel(theme),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: barWidth.clamp(0.05, 1.0),
            minHeight: 6,
            backgroundColor: AppColors.skyBlue.withValues(alpha: 0.12),
            color: AppColors.skyBlue,
          ),
        ),
        Text(
          '${snapshot.totalRides} corridas · '
          '${CurrencyFormatter.format(snapshot.avgPerRide)}/corrida',
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.secondaryLabel(theme),
          ),
        ),
      ],
    );
  }
}
