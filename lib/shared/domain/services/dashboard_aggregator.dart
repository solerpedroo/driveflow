import '../../../core/constants/date_range_period.dart';
import '../../../core/utils/date_utils.dart';
import '../../../features/earnings/domain/entities/earning_entity.dart';
import '../../../features/expenses/domain/entities/expense_entity.dart';
import '../../../features/fuel/domain/entities/fuel_log_entity.dart';
import '../../../features/goals/domain/entities/goal_entity.dart';
import '../models/daily_profit_point.dart';
import '../models/dashboard_snapshot.dart';
import 'profit_calculator.dart';

/// Consolida ganhos, despesas e combustível para o dashboard.
abstract final class DashboardAggregator {
  static DashboardSnapshot build({
    required List<EarningEntity> earnings,
    required List<ExpenseEntity> expenses,
    required List<FuelLogEntity> fuelLogs,
    DateTime? anchor,
  }) {
    final now = anchor ?? DateTime.now();
    final todayRange = dateRangeForGoalPeriod(GoalPeriod.daily, now);
    final monthRange = dateRangeForGoalPeriod(GoalPeriod.monthly, now);
    final weekRange = dateRangeForGoalPeriod(GoalPeriod.weekly, now);

    return DashboardSnapshot(
      today: ProfitCalculator.summarize(
        earnings: earnings,
        expenses: expenses,
        fuelLogs: fuelLogs,
        range: todayRange,
      ),
      month: ProfitCalculator.summarize(
        earnings: earnings,
        expenses: expenses,
        fuelLogs: fuelLogs,
        range: monthRange,
      ),
      weekProfits: _weekProfits(
        earnings: earnings,
        expenses: expenses,
        range: weekRange,
        anchor: now,
      ),
    );
  }

  static List<DailyProfitPoint> _weekProfits({
    required List<EarningEntity> earnings,
    required List<ExpenseEntity> expenses,
    required DateRange range,
    required DateTime anchor,
  }) {
    final start = DateUtilsDriveFlow.startOfWeek(anchor);
    return List.generate(7, (index) {
      final day = start.add(Duration(days: index));
      final dayRange = DateRange(
        start: DateUtilsDriveFlow.startOfDay(day),
        end: DateUtilsDriveFlow.endOfDay(day),
      );
      final summary = ProfitCalculator.summarize(
        earnings: earnings,
        expenses: expenses,
        fuelLogs: const [],
        range: dayRange,
      );
      return DailyProfitPoint(
        date: day,
        profit: summary.profit,
        weekdayLabel: _weekdayLabel(day.weekday),
      );
    });
  }

  static const _weekdayLabels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  static String _weekdayLabel(int weekday) => _weekdayLabels[weekday - 1];
}
