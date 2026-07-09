import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/design_system/df_segmented_control.dart';
import '../../../../shared/widgets/design_system/df_skeleton.dart';
import '../../../vehicle/presentation/widgets/vehicle_scope_chip.dart';
import '../providers/insights_providers.dart';
import '../widgets/best_time_slots_card.dart';
import '../widgets/insights_story_header.dart';
import '../widgets/maintenance_prediction_card.dart';
import '../widgets/weekly_goal_projection_card.dart';

/// Tela de insights operacionais — melhor horário, manutenção e meta.
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final slotsLimit = ref.watch(insightsSlotsLimitProvider);
    final slotsAsync = ref.watch(earningsHeatmapProvider);
    final predictionsAsync = ref.watch(maintenancePredictionsProvider);
    final projectionAsync = ref.watch(weeklyGoalProjectionProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Insights'),
        backgroundColor: Colors.transparent,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            sliver: SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.centerLeft,
                child: VehicleScopeChip(),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            sliver: const SliverToBoxAdapter(
              child: InsightsStoryHeader(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Melhor horário',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            sliver: SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DfSegmentedControl<InsightsSlotsLimit>(
                  segments: InsightsSlotsLimit.values,
                  selected: slotsLimit,
                  labelBuilder: (l) => l.label,
                  onChanged: (l) =>
                      ref.read(insightsSlotsLimitProvider.notifier).state = l,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            sliver: SliverToBoxAdapter(
              child: slotsAsync.when(
                loading: () => const DfSkeleton(itemCount: 3),
                error: (e, _) => Text('Erro: $e'),
                data: (slots) => BestTimeSlotsCard(
                  slots: slots.take(slotsLimit.count).toList(growable: false),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Manutenção',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            sliver: SliverToBoxAdapter(
              child: predictionsAsync.when(
                loading: () => const DfSkeleton(itemCount: 2),
                error: (e, _) => Text('Erro: $e'),
                data: (predictions) =>
                    MaintenancePredictionCard(predictions: predictions),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Meta semanal',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            sliver: SliverToBoxAdapter(
              child: projectionAsync.when(
                loading: () => const DfSkeleton(itemCount: 2),
                error: (e, _) => Text('Erro: $e'),
                data: (projection) =>
                    WeeklyGoalProjectionCard(projection: projection),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
