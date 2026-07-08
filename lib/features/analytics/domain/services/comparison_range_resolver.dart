import '../../../goals/domain/entities/goal_entity.dart';
import '../entities/analytics_enums.dart';

/// Resolve intervalos atual e de referência para comparação.
abstract final class ComparisonRangeResolver {
  static ComparisonPeriods resolve({
    required GoalPeriod period,
    required ComparisonReference reference,
    DateTime? anchor,
  }) {
    final now = anchor ?? DateTime.now();
    final currentRange = dateRangeForGoalPeriod(period, now);
    final referenceRange = switch (reference) {
      ComparisonReference.previousPeriod => _previousRange(period, now),
      ComparisonReference.sameMonthLastYear =>
        _sameMonthLastYearRange(period, now),
    };

    return ComparisonPeriods(
      period: period,
      reference: reference,
      currentRange: currentRange,
      referenceRange: referenceRange,
    );
  }

  static DateRange _previousRange(GoalPeriod period, DateTime anchor) {
    switch (period) {
      case GoalPeriod.daily:
        final previousDay = anchor.subtract(const Duration(days: 1));
        return dateRangeForGoalPeriod(GoalPeriod.daily, previousDay);
      case GoalPeriod.weekly:
        final previousWeekAnchor =
            dateRangeForGoalPeriod(GoalPeriod.weekly, anchor)
                .start
                .subtract(const Duration(days: 7));
        return dateRangeForGoalPeriod(GoalPeriod.weekly, previousWeekAnchor);
      case GoalPeriod.monthly:
        final previousMonth = DateTime(anchor.year, anchor.month - 1, anchor.day);
        return dateRangeForGoalPeriod(GoalPeriod.monthly, previousMonth);
      case GoalPeriod.yearly:
        return dateRangeForGoalPeriod(
          GoalPeriod.yearly,
          DateTime(anchor.year - 1, anchor.month, anchor.day),
        );
    }
  }

  static DateRange _sameMonthLastYearRange(GoalPeriod period, DateTime anchor) {
    if (period == GoalPeriod.monthly) {
      return dateRangeForGoalPeriod(
        GoalPeriod.monthly,
        DateTime(anchor.year - 1, anchor.month, anchor.day),
      );
    }
    // Para outros períodos, cai no equivalente deslocado 1 ano.
    return dateRangeForGoalPeriod(
      period,
      DateTime(anchor.year - 1, anchor.month, anchor.day),
    );
  }
}
