import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../vehicle/presentation/widgets/vehicle_scope_chip.dart';
import '../providers/insights_providers.dart';
import '../widgets/best_time_slots_card.dart';
import '../widgets/maintenance_prediction_card.dart';
import '../widgets/weekly_goal_projection_card.dart';

/// Tela de insights operacionais — melhor horário, manutenção e meta.
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final slotsAsync = ref.watch(earningsHeatmapProvider);
    final predictionsAsync = ref.watch(maintenancePredictionsProvider);
    final projectionAsync = ref.watch(weeklyGoalProjectionProvider);

    return Scaffold(
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
            sliver: SliverToBoxAdapter(
              child: Text(
                'Recomendações inteligentes',
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            sliver: SliverToBoxAdapter(
              child: slotsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Erro: $e'),
                data: (slots) => BestTimeSlotsCard(
                  slots: slots.take(5).toList(growable: false),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            sliver: SliverToBoxAdapter(
              child: predictionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Erro: $e'),
                data: (predictions) =>
                    MaintenancePredictionCard(predictions: predictions),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            sliver: SliverToBoxAdapter(
              child: projectionAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
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
