import '../../../earnings/domain/entities/earning_entity.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../fuel/domain/entities/fuel_log_entity.dart';
import '../../../goals/domain/entities/goal_entity.dart';
import '../../../../shared/domain/models/period_summary.dart';
import '../../../../shared/domain/services/profit_calculator.dart';
import '../entities/analytics_enums.dart';
import '../entities/period_comparison_result.dart';
import 'comparison_range_resolver.dart';

/// Compara indicadores financeiros entre período atual e referência.
abstract final class PeriodComparisonCalculator {
  static PeriodComparisonResult compare({
    required GoalPeriod period,
    required ComparisonReference reference,
    required List<EarningEntity> earnings,
    required List<ExpenseEntity> expenses,
    required List<FuelLogEntity> fuelLogs,
    DateTime? anchor,
  }) {
    final ranges = ComparisonRangeResolver.resolve(
      period: period,
      reference: reference,
      anchor: anchor,
    );

    final current = ProfitCalculator.summarize(
      earnings: earnings,
      expenses: expenses,
      fuelLogs: fuelLogs,
      range: ranges.currentRange,
    );
    final previous = ProfitCalculator.summarize(
      earnings: earnings,
      expenses: expenses,
      fuelLogs: fuelLogs,
      range: ranges.referenceRange,
    );

    return PeriodComparisonResult(
      period: period,
      reference: reference,
      metrics: _buildMetrics(current: current, previous: previous),
    );
  }

  static List<PeriodMetricDelta> _buildMetrics({
    required PeriodSummary current,
    required PeriodSummary previous,
  }) {
    return [
      _metric('Receita', current.revenue, previous.revenue),
      _metric('Despesas', current.expenses, previous.expenses),
      _metric('Lucro', current.profit, previous.profit),
      _metric('Lucro / hora', current.profitPerHour ?? 0, previous.profitPerHour ?? 0),
      _metric('Lucro / km', current.profitPerKm ?? 0, previous.profitPerKm ?? 0),
      _metric('Combustível', current.fuelExpense, previous.fuelExpense),
    ];
  }

  static PeriodMetricDelta _metric(
    String label,
    double current,
    double previous,
  ) {
    final delta = current - previous;
    final deltaPercent = previous == 0 ? null : (delta / previous) * 100;
    return PeriodMetricDelta(
      label: label,
      current: current,
      previous: previous,
      delta: delta,
      deltaPercent: deltaPercent,
    );
  }
}
