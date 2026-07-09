import '../../../earnings/domain/entities/earning_entity.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../fuel/domain/entities/fuel_log_entity.dart';
import '../../../goals/domain/entities/goal_entity.dart';
import '../../../insights/domain/entities/earning_time_slot.dart';
import '../../../maintenance/domain/entities/maintenance_entity.dart';
import '../../../maintenance/domain/services/maintenance_due_checker.dart';
import '../../../../shared/domain/models/period_summary.dart';
import '../../../../shared/domain/services/profit_calculator.dart';

/// Snapshot local do contexto enviado à IA (preview/debug).
class AiContextSnapshot {
  const AiContextSnapshot({
    required this.periodDays,
    required this.today,
    required this.month,
    required this.year,
    required this.goals,
    required this.earningsCount,
    required this.expensesCount,
    required this.fuelLogsCount,
    required this.maintenanceAlerts,
    required this.lastFuelCostPerKm,
    this.topEarningSlots = const [],
  });

  final int periodDays;
  final PeriodSummary today;
  final PeriodSummary month;
  final PeriodSummary year;
  final GoalEntity? goals;
  final int earningsCount;
  final int expensesCount;
  final int fuelLogsCount;
  final int maintenanceAlerts;
  final double? lastFuelCostPerKm;
  final List<EarningTimeSlot> topEarningSlots;

  Map<String, dynamic> toJson() {
    return {
      'periodDays': periodDays,
      'today': _summaryJson(today),
      'month': _summaryJson(month),
      'year': _summaryJson(year),
      'goals': goals == null
          ? null
          : {
              'daily': goals!.daily,
              'weekly': goals!.weekly,
              'monthly': goals!.monthly,
              'yearly': goals!.yearly,
            },
      'counts': {
        'earnings': earningsCount,
        'expenses': expensesCount,
        'fuelLogs': fuelLogsCount,
        'maintenanceAlerts': maintenanceAlerts,
      },
      'lastFuelCostPerKm': lastFuelCostPerKm,
      'topEarningSlots': topEarningSlots
          .map(
            (slot) => {
              'weekday': slot.weekdayLabel,
              'hour': slot.hourLabel,
              'profitPerHour': slot.profitPerHour,
            },
          )
          .toList(growable: false),
    };
  }

  Map<String, dynamic> _summaryJson(PeriodSummary summary) {
    return {
      'revenue': summary.revenue,
      'expenses': summary.expenses,
      'profit': summary.profit,
      'rides': summary.rides,
      'workedHours': summary.workedHours,
      'fuelExpense': summary.fuelExpense,
      'profitPerHour': summary.profitPerHour,
      'profitPerKm': summary.profitPerKm,
    };
  }
}

/// Monta contexto local a partir dos dados do app.
abstract final class AiContextBuilder {
  static AiContextSnapshot build({
    required List<EarningEntity> earnings,
    required List<ExpenseEntity> expenses,
    required List<FuelLogEntity> fuelLogs,
    required List<MaintenanceEntity> maintenanceRecords,
    required GoalEntity? goals,
    required double? currentOdometerKm,
    int periodDays = 90,
    List<EarningTimeSlot> topEarningSlots = const [],
  }) {
    final anchor = DateTime.now();
    final todayRange = dateRangeForGoalPeriod(GoalPeriod.daily, anchor);
    final monthRange = dateRangeForGoalPeriod(GoalPeriod.monthly, anchor);
    final yearRange = dateRangeForGoalPeriod(GoalPeriod.yearly, anchor);

    final today = ProfitCalculator.summarize(
      earnings: earnings,
      expenses: expenses,
      fuelLogs: fuelLogs,
      range: todayRange,
    );
    final month = ProfitCalculator.summarize(
      earnings: earnings,
      expenses: expenses,
      fuelLogs: fuelLogs,
      range: monthRange,
    );
    final year = ProfitCalculator.summarize(
      earnings: earnings,
      expenses: expenses,
      fuelLogs: fuelLogs,
      range: yearRange,
    );

    var alerts = 0;
    if (currentOdometerKm != null) {
      for (final record in maintenanceRecords) {
        final status = MaintenanceDueChecker.check(
          record: record,
          currentOdometerKm: currentOdometerKm,
        );
        if (status != MaintenanceDueStatus.ok) alerts++;
      }
    }

    return AiContextSnapshot(
      periodDays: periodDays,
      today: today,
      month: month,
      year: year,
      goals: goals,
      earningsCount: earnings.length,
      expensesCount: expenses.length,
      fuelLogsCount: fuelLogs.length,
      maintenanceAlerts: alerts,
      lastFuelCostPerKm: fuelLogs.isEmpty ? null : fuelLogs.first.costPerKm,
      topEarningSlots: topEarningSlots,
    );
  }

  static String formatForPrompt(AiContextSnapshot snapshot) {
    final goals = snapshot.goals;
    final goalsLine = goals == null
        ? 'Metas não configuradas'
        : 'Metas BRL — diária: ${goals.daily}, semanal: ${goals.weekly}, '
            'mensal: ${goals.monthly}, anual: ${goals.yearly}';

    return [
      'Período analisado: ${snapshot.periodDays} dias',
      'Hoje — lucro: ${snapshot.today.profit}, receita: ${snapshot.today.revenue}',
      'Mês — lucro: ${snapshot.month.profit}, receita: ${snapshot.month.revenue}',
      'Ano — lucro: ${snapshot.year.profit}, receita: ${snapshot.year.revenue}',
      goalsLine,
      'Alertas de manutenção: ${snapshot.maintenanceAlerts}',
      'Registros — ganhos: ${snapshot.earningsCount}, despesas: '
          '${snapshot.expensesCount}, abastecimentos: ${snapshot.fuelLogsCount}',
      if (snapshot.lastFuelCostPerKm != null)
        'Último custo/km combustível: ${snapshot.lastFuelCostPerKm}',
      if (snapshot.topEarningSlots.isNotEmpty)
        'Melhor horário: ${snapshot.topEarningSlots.first.weekdayLabel} '
            '${snapshot.topEarningSlots.first.hourLabel} '
            '(${snapshot.topEarningSlots.first.profitPerHour.toStringAsFixed(2)}/h)',
    ].join('\n');
  }
}
