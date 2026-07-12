import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/value_visibility_provider.dart';
import '../../../../shared/widgets/design_system/df_card.dart';
import '../../../../shared/widgets/design_system/df_period_pill_chip.dart';
import '../../../../shared/widgets/design_system/df_skeleton.dart';
import '../../../../shared/widgets/design_system/df_subpage_scaffold.dart';
import '../../../vehicle/presentation/widgets/vehicle_scope_chip.dart';
import '../providers/insights_providers.dart';
import '../widgets/best_time_slots_card.dart';
import '../widgets/insights_story_header.dart';
import '../widgets/maintenance_prediction_card.dart';
import '../widgets/weekly_goal_projection_card.dart';

/// Insights operacionais — DNA Início / Perfil.
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotsLimit = ref.watch(insightsSlotsLimitProvider);
    final slotsAsync = ref.watch(earningsHeatmapProvider);
    final predictionsAsync = ref.watch(maintenancePredictionsProvider);
    final projectionAsync = ref.watch(weeklyGoalProjectionProvider);
    final hidden = ref.watch(valueVisibilityHiddenProvider);
    final brightness = Theme.of(context).brightness;

    return DfSubpageScaffold(
      title: 'Insights',
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: VehicleScopeChip(),
        ),
        const InsightsStoryHeader(),
        DfCard(
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
                'Melhor horário',
                style: AppTypography.labelCaps(brightness),
              ),
              const SizedBox(height: AppSpacing.md),
              DfPeriodPillRow<InsightsSlotsLimit>(
                segments: InsightsSlotsLimit.values,
                selected: slotsLimit,
                labelBuilder: (l) => l.label,
                onChanged: (l) =>
                    ref.read(insightsSlotsLimitProvider.notifier).state = l,
              ),
            ],
          ),
        ),
        slotsAsync.when(
          loading: () => const DfSkeleton(itemCount: 3),
          error: (e, _) => Text(
            'Não foi possível carregar. Tente novamente.',
            style: AppTypography.iosBody(brightness),
          ),
          data: (slots) => BestTimeSlotsCard(
            slots: slots.take(slotsLimit.count).toList(growable: false),
          ),
        ),
        predictionsAsync.when(
          loading: () => const DfSkeleton(itemCount: 2),
          error: (e, _) => Text(
            'Não foi possível carregar. Tente novamente.',
            style: AppTypography.iosBody(brightness),
          ),
          data: (predictions) =>
              MaintenancePredictionCard(predictions: predictions),
        ),
        projectionAsync.when(
          loading: () => const DfSkeleton(itemCount: 2),
          error: (e, _) => Text(
            'Não foi possível carregar. Tente novamente.',
            style: AppTypography.iosBody(brightness),
          ),
          data: (projection) => WeeklyGoalProjectionCard(
            projection: projection,
            hideValue: hidden,
          ),
        ),
      ],
    );
  }
}
