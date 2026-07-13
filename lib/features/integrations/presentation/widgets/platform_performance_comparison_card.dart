import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../domain/entities/platform_performance_snapshot.dart';
import '../providers/integrations_providers.dart';

/// Comparativo visual de R\$/hora entre plataformas.
class PlatformPerformanceComparisonCard extends ConsumerWidget {
  const PlatformPerformanceComparisonCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final performance = ref.watch(platformPerformanceProvider);

    return performance.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (snapshots) {
        final withData = snapshots.where((s) => s.hasData).toList();
        if (withData.isEmpty) return const SizedBox.shrink();

        final maxAvg = withData
            .map((s) => s.avgPerHour)
            .fold<double>(0, (a, b) => a > b ? a : b);

        return DfCard(
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
                    maxAvgPerHour: maxAvg,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
    final barWidth =
        maxAvgPerHour > 0 ? snapshot.avgPerHour / maxAvgPerHour : 0.0;

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
