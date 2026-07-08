import '../../../earnings/domain/entities/earning_entity.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../goals/domain/entities/goal_entity.dart';
import '../entities/weekly_goal_projection.dart';

/// Projeta atingimento da meta semanal com base no ritmo atual.
abstract final class WeeklyGoalProjectionCalculator {
  static WeeklyGoalProjection compute({
    required GoalEntity? goals,
    required List<EarningEntity> earnings,
    required List<ExpenseEntity> expenses,
    DateTime? now,
  }) {
    final anchor = now ?? DateTime.now();
    final range = dateRangeForGoalPeriod(GoalPeriod.weekly, anchor);
    final target = goals?.weekly ?? 0;

    var revenue = 0.0;
    var expenseTotal = 0.0;

    for (final earning in earnings) {
      if (range.contains(earning.date)) revenue += earning.amount;
    }
    for (final expense in expenses) {
      if (range.contains(expense.date)) expenseTotal += expense.amount;
    }

    final profit = revenue - expenseTotal;
    final daysElapsed = anchor.difference(range.start).inDays + 1;
    final daysRemaining = range.end.difference(anchor).inDays;
    final totalDays = daysElapsed + daysRemaining;

    final projected = daysElapsed > 0 && totalDays > 0
        ? profit / daysElapsed * totalDays
        : profit;

    return WeeklyGoalProjection(
      targetAmount: target,
      actualProfit: profit,
      projectedProfit: projected,
      daysElapsed: daysElapsed.clamp(1, 7),
      daysRemaining: daysRemaining.clamp(0, 7),
      hasTarget: target > 0,
    );
  }
}
