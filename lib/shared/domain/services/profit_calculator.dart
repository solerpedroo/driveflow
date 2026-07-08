import '../../../core/constants/app_constants.dart';
import '../../../core/constants/date_range_period.dart';
import '../../../core/utils/transaction_filters.dart';
import '../../../features/earnings/domain/entities/earning_entity.dart';
import '../../../features/expenses/domain/entities/expense_entity.dart';
import '../../../features/fuel/domain/entities/fuel_log_entity.dart';
import '../models/period_summary.dart';

/// Cálculos de lucro, lucro/hora e lucro/km.
abstract final class ProfitCalculator {
  static double profit(double revenue, double expenses) => revenue - expenses;

  static double? profitPerHour(double profitValue, double workedHours) {
    if (workedHours <= 0) return null;
    return profitValue / workedHours;
  }

  static double? profitPerKm(double profitValue, double kmDriven) {
    if (kmDriven <= 0) return null;
    return profitValue / kmDriven;
  }

  static double? averageCostPerKm(List<FuelLogEntity> fuelLogs) {
    final withMetric = fuelLogs.where((log) => log.costPerKm != null).toList();
    if (withMetric.isEmpty) return null;
    final total = withMetric.fold<double>(
      0,
      (sum, log) => sum + log.costPerKm!,
    );
    return total / withMetric.length;
  }

  static double kmDrivenFromFuelLogs(List<FuelLogEntity> fuelLogs) {
    if (fuelLogs.isEmpty) return 0;

    final withMetrics = fuelLogs
        .where((log) => log.kmPerLiter != null && log.liters > 0)
        .toList();
    if (withMetrics.isNotEmpty) {
      return withMetrics.fold<double>(
        0,
        (sum, log) => sum + log.kmPerLiter! * log.liters,
      );
    }

    if (fuelLogs.length < 2) return 0;
    final sorted = [...fuelLogs]
      ..sort((a, b) => a.odometerKm.compareTo(b.odometerKm));
    var km = 0.0;
    for (var i = 1; i < sorted.length; i++) {
      final delta = sorted[i].odometerKm - sorted[i - 1].odometerKm;
      if (delta > 0) km += delta;
    }
    return km;
  }

  static PeriodSummary summarize({
    required List<EarningEntity> earnings,
    required List<ExpenseEntity> expenses,
    required List<FuelLogEntity> fuelLogs,
    required DateRange range,
  }) {
    final filteredEarnings = TransactionFilters.byDateRange(
      earnings,
      range,
      (e) => e.date,
    );
    final filteredExpenses = TransactionFilters.byDateRange(
      expenses,
      range,
      (e) => e.date,
    );
    final filteredFuel = TransactionFilters.byDateRange(
      fuelLogs,
      range,
      (log) => log.createdAt ?? DateTime.now(),
    );

    final revenue = TransactionFilters.sumAmounts(
      filteredEarnings,
      (e) => e.amount,
    );
    final expenseTotal = TransactionFilters.sumAmounts(
      filteredExpenses,
      (e) => e.amount,
    );
    final profitValue = profit(revenue, expenseTotal);
    final workedHours = filteredEarnings.fold<double>(
      0,
      (sum, e) => sum + e.workedHours,
    );
    final rides = filteredEarnings.fold<int>(
      0,
      (sum, e) => sum + e.rides,
    );
    final kmDriven = kmDrivenFromFuelLogs(filteredFuel);
    final fuelExpense = filteredExpenses
        .where((e) => e.category == ExpenseCategory.fuel)
        .fold<double>(0, (sum, e) => sum + e.amount);

    return PeriodSummary(
      revenue: revenue,
      expenses: expenseTotal,
      profit: profitValue,
      workedHours: workedHours,
      rides: rides,
      kmDriven: kmDriven,
      fuelExpense: fuelExpense,
      profitPerHour: profitPerHour(profitValue, workedHours),
      profitPerKm: profitPerKm(profitValue, kmDriven),
      avgCostPerKm: averageCostPerKm(filteredFuel),
    );
  }
}
