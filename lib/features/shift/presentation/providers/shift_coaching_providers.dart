import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../integrations/domain/entities/platform_shift_plan.dart';
import '../../../integrations/domain/services/platform_shift_plan_builder.dart';
import '../../../integrations/presentation/providers/platform_analytics_providers.dart';
import '../domain/entities/shift_coach_insight.dart';
import '../domain/services/shift_coach_analyzer.dart';
import '../domain/services/shift_plan_advisor.dart';
import 'shift_history_providers.dart';

final shiftCoachInsightProvider = Provider<ShiftCoachInsight?>((ref) {
  final history = ref.watch(shiftHistoryStreamProvider).valueOrNull ?? const [];
  return ShiftCoachAnalyzer.analyze(history: history);
});

/// Plano de turno ajustado pelo histórico recente + heatmap.
final adaptiveShiftPlanProvider =
    Provider<AsyncValue<PlatformShiftPlan>>((ref) {
  final heatmap = ref.watch(platformHeatmapProvider);
  final history = ref.watch(shiftHistoryStreamProvider).valueOrNull ?? const [];
  final recommendation = ref.watch(platformShiftRecommendationProvider);

  return heatmap.when(
    loading: () => const AsyncLoading(),
    error: (error, stackTrace) => AsyncError(error, stackTrace),
    data: (slots) {
      final now = DateTime.now();
      if (slots.isNotEmpty) {
        return AsyncData(
          ShiftPlanAdvisor.build(
            heatmapSlots: slots,
            history: history,
            currentWeekday: now.weekday,
            currentHour: now.hour,
          ),
        );
      }

      final rec = recommendation.valueOrNull;
      if (rec != null) {
        return AsyncData(
          PlatformShiftPlanBuilder.fallback(
            platform: rec.recommended,
            revenuePerHour: 0,
            currentHour: now.hour,
          ),
        );
      }

      return const AsyncData(
        PlatformShiftPlan(blocks: [], totalHours: 0, projectedRevenue: 0),
      );
    },
  );
});
