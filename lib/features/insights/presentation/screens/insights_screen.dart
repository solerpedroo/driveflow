import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../shared/widgets/design_system/df_period_pill_chip.dart';
import '../../../../shared/widgets/design_system/df_section_header.dart';
import '../../../../shared/widgets/design_system/df_skeleton.dart';
import '../../../../shared/widgets/design_system/df_subpage_scaffold.dart';
import '../../../vehicle/presentation/widgets/vehicle_scope_chip.dart';
import '../providers/insights_providers.dart';
import '../widgets/best_time_slots_card.dart';
import '../widgets/insights_story_header.dart';
import '../widgets/maintenance_prediction_card.dart';
import '../widgets/weekly_goal_projection_card.dart';

/// Insights operacionais — layout Mescla com seções claras.
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotsLimit = ref.watch(insightsSlotsLimitProvider);
    final slotsAsync = ref.watch(earningsHeatmapProvider);
    final predictionsAsync = ref.watch(maintenancePredictionsProvider);
    final projectionAsync = ref.watch(weeklyGoalProjectionProvider);

    return DfSubpageScaffold(
      title: 'Insights',
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: VehicleScopeChip(),
        ),
        const InsightsStoryHeader(),
        const DfSectionHeader(title: 'Melhor horário', eyebrow: 'Operação'),
        DfPeriodPillRow<InsightsSlotsLimit>(
          segments: InsightsSlotsLimit.values,
          selected: slotsLimit,
          labelBuilder: (l) => l.label,
          onChanged: (l) =>
              ref.read(insightsSlotsLimitProvider.notifier).state = l,
        ),
        slotsAsync.when(
          loading: () => const DfSkeleton(itemCount: 3),
          error: (e, _) => Text('Não foi possível carregar. Tente novamente.'),
          data: (slots) => BestTimeSlotsCard(
            slots: slots.take(slotsLimit.count).toList(growable: false),
          ),
        ),
        const DfSectionHeader(title: 'Manutenção prevista', eyebrow: 'Veículo'),
        predictionsAsync.when(
          loading: () => const DfSkeleton(itemCount: 2),
          error: (e, _) => Text('Não foi possível carregar. Tente novamente.'),
          data: (predictions) =>
              MaintenancePredictionCard(predictions: predictions),
        ),
        const DfSectionHeader(title: 'Meta semanal', eyebrow: 'Projeção'),
        projectionAsync.when(
          loading: () => const DfSkeleton(itemCount: 2),
          error: (e, _) => Text('Não foi possível carregar. Tente novamente.'),
          data: (projection) =>
              WeeklyGoalProjectionCard(projection: projection),
        ),
      ],
    );
  }
}
