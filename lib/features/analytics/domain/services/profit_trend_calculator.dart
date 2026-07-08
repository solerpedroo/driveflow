import '../../../../core/constants/date_range_period.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../earnings/domain/entities/earning_entity.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../../shared/domain/models/daily_profit_point.dart';
import '../../../../shared/domain/services/profit_calculator.dart';
import '../entities/analytics_enums.dart';

/// Série temporal de lucro diário para gráficos de tendência.
abstract final class ProfitTrendCalculator {
  static List<DailyProfitPoint> build({
    required List<EarningEntity> earnings,
    required List<ExpenseEntity> expenses,
    required TrendWindow window,
    DateTime? anchor,
  }) {
    final now = anchor ?? DateTime.now();
    final days = window.days;

    return List.generate(days, (index) {
      final day = DateUtilsDriveFlow.startOfDay(
        now.subtract(Duration(days: days - 1 - index)),
      );
      final range = DateRange(
        start: day,
        end: DateUtilsDriveFlow.endOfDay(day),
      );
      final summary = ProfitCalculator.summarize(
        earnings: earnings,
        expenses: expenses,
        fuelLogs: const [],
        range: range,
      );

      return DailyProfitPoint(
        date: day,
        profit: summary.profit,
        weekdayLabel: DateUtilsDriveFlow.dayMonth.format(day),
      );
    });
  }
}
