import '../../../earnings/domain/entities/earning_entity.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../entities/profit_forecast_result.dart';
import 'profit_trend_calculator.dart';
import '../entities/analytics_enums.dart';

/// Previsão local de lucro com base na média dos últimos 90 dias.
abstract final class ProfitForecastCalculator {
  static const optimisticFactor = 1.15;
  static const pessimisticFactor = 0.85;

  static ProfitForecastResult compute({
    required List<EarningEntity> earnings,
    required List<ExpenseEntity> expenses,
    DateTime? anchor,
  }) {
    final points = ProfitTrendCalculator.build(
      earnings: earnings,
      expenses: expenses,
      window: TrendWindow.days90,
      anchor: anchor,
    );

    final activeDays = points.where((point) => point.profit != 0).toList();
    final sample = activeDays.isEmpty ? points : activeDays;
    final totalProfit = sample.fold<double>(0, (sum, p) => sum + p.profit);
    final average = sample.isEmpty ? 0.0 : totalProfit / sample.length;

    return ProfitForecastResult(
      forecast7Days: average * 7,
      forecast30Days: average * 30,
      optimistic30Days: average * 30 * optimisticFactor,
      pessimistic30Days: average * 30 * pessimisticFactor,
      averageDailyProfit: average,
      sampleDays: sample.length,
    );
  }
}
