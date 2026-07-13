import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/shift_analytics_period.dart';
import '../../domain/entities/shift_analytics_summary.dart';
import '../../domain/services/shift_analytics_calculator.dart';
import 'shift_history_providers.dart';

final shiftAnalyticsPeriodProvider =
    StateProvider<ShiftAnalyticsPeriod>((ref) => ShiftAnalyticsPeriod.days7);

final shiftAnalyticsSummaryProvider = Provider<ShiftAnalyticsSummary>((ref) {
  final history = ref.watch(shiftHistoryStreamProvider).valueOrNull ?? const [];
  final period = ref.watch(shiftAnalyticsPeriodProvider);
  return ShiftAnalyticsCalculator.calculate(
    history: history,
    period: period,
  );
});
