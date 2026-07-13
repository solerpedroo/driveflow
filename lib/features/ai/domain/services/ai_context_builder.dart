import '../../../../core/constants/ride_platforms.dart';
import '../../../integrations/domain/entities/platform_consistency_snapshot.dart';
import '../../../integrations/domain/entities/platform_heatmap_slot.dart';
import '../../../integrations/domain/entities/platform_net_profit_slice.dart';
import '../../../integrations/domain/entities/platform_score_snapshot.dart';
import '../../../integrations/domain/services/platform_consistency_analyzer.dart';
import '../../../integrations/domain/services/platform_heatmap_builder.dart';
import '../../../integrations/domain/services/platform_net_profit_calculator.dart';
import '../../../integrations/domain/services/platform_profit_per_km_analyzer.dart';
import '../../../integrations/domain/services/platform_revenue_trend_calculator.dart';
import '../../../integrations/domain/services/platform_score_calculator.dart';
import '../../../integrations/domain/services/platform_analytics_breakdown.dart';
import '../../../integrations/domain/entities/platform_revenue_trend_point.dart';
import '../../../integrations/domain/entities/platform_trip_entity.dart';
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
    this.platformBreakdown = const [],
    this.platformTripCount = 0,
    this.lowestTakeRatePlatform,
    this.platformTrendSummary = const [],
    this.platformConsistency = const [],
    this.platformNetProfit = const [],
    this.platformProfitPerKm = const [],
    this.topHeatmapSlots = const [],
    this.platformScores = const [],
    this.activeShift,
    this.shiftHistoryWeek,
    this.shiftCoaching,
    this.shiftAnalytics,
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
  final List<PlatformRevenueSlice> platformBreakdown;
  final int platformTripCount;
  final String? lowestTakeRatePlatform;
  final List<PlatformRevenueTrendPoint> platformTrendSummary;
  final List<PlatformConsistencySnapshot> platformConsistency;
  final List<PlatformNetProfitSlice> platformNetProfit;
  final List<PlatformProfitPerKmSnapshot> platformProfitPerKm;
  final List<PlatformHeatmapSlot> topHeatmapSlots;
  final List<PlatformScoreSnapshot> platformScores;
  final Map<String, dynamic>? activeShift;
  final Map<String, dynamic>? shiftHistoryWeek;
  final Map<String, dynamic>? shiftCoaching;
  final Map<String, dynamic>? shiftAnalytics;

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
      'platformBreakdown': platformBreakdown
          .map(
            (s) => {
              'platform': s.platform.label,
              'amount': s.amount,
              'rides': s.rides,
            },
          )
          .toList(growable: false),
      'platformTripCount': platformTripCount,
      'platformTrend': platformTrendSummary
          .take(7)
          .map(
            (p) => {
              'date': p.date.toIso8601String(),
              'total': p.total,
            },
          )
          .toList(growable: false),
      'platformConsistency': platformConsistency
          .map(
            (c) => {
              'platform': c.platform.label,
              'score': c.consistencyScore,
              'avgDaily': c.avgDailyProfit,
            },
          )
          .toList(growable: false),
      'platformNetProfit': platformNetProfit
          .map(
            (n) => {
              'platform': n.platform.label,
              'net': n.netAmount,
            },
          )
          .toList(growable: false),
      'platformProfitPerKm': platformProfitPerKm
          .map(
            (p) => {
              'platform': p.platform.label,
              'profitPerKm': p.profitPerKm,
            },
          )
          .toList(growable: false),
      'topHeatmapSlots': topHeatmapSlots
          .map(
            (h) => {
              'platform': h.platform.label,
              'weekday': h.weekday,
              'hour': h.hour,
              'revenuePerHour': h.revenuePerHour,
            },
          )
          .toList(growable: false),
      'platformScores': platformScores
          .map(
            (s) => {
              'platform': s.platform.label,
              'score': s.score,
            },
          )
          .toList(growable: false),
      if (activeShift != null) 'activeShift': activeShift,
      if (shiftHistoryWeek != null) 'shiftHistoryWeek': shiftHistoryWeek,
      if (shiftCoaching != null) 'shiftCoaching': shiftCoaching,
      if (shiftAnalytics != null) 'shiftAnalytics': shiftAnalytics,
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
    List<PlatformTripEntity> platformTrips = const [],
    Map<String, dynamic>? activeShift,
    Map<String, dynamic>? shiftHistoryWeek,
    Map<String, dynamic>? shiftCoaching,
    Map<String, dynamic>? shiftAnalytics,
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

    final cutoff = anchor.subtract(Duration(days: periodDays));
    final periodEarnings = earnings
        .where((e) => !e.date.isBefore(cutoff))
        .toList();
    final periodTrips = platformTrips
        .where((t) => !t.startedAt.isBefore(cutoff))
        .toList();
    final fuelCostPerKm = fuelLogs.isEmpty ? 0.0 : (fuelLogs.first.costPerKm ?? 0);
    final heatmap = PlatformHeatmapBuilder.build(trips: periodTrips);

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
      platformBreakdown: PlatformAnalyticsBreakdown.fromTripsOrEarnings(
        trips: periodTrips,
        earnings: periodEarnings,
      ),
      platformTripCount: periodTrips.length,
      lowestTakeRatePlatform: _lowestTakeRate(periodTrips),
      platformTrendSummary: periodTrips.isNotEmpty
          ? PlatformRevenueTrendCalculator.fromTrips(
              trips: periodTrips,
              days: 7,
            )
          : PlatformRevenueTrendCalculator.fromEarnings(
              earnings: periodEarnings,
              days: 7,
            ),
      platformConsistency: PlatformConsistencyAnalyzer.analyze(
        trips: periodTrips,
      ),
      platformNetProfit: fuelCostPerKm > 0
          ? PlatformNetProfitCalculator.fromTrips(
              trips: periodTrips,
              fuelCostPerKm: fuelCostPerKm,
            )
          : const [],
      platformProfitPerKm: fuelCostPerKm > 0
          ? PlatformProfitPerKmAnalyzer.analyze(
              trips: periodTrips,
              fuelCostPerKm: fuelCostPerKm,
            )
          : const [],
      topHeatmapSlots: heatmap.take(5).toList(growable: false),
      platformScores: PlatformScoreCalculator.calculate(periodTrips),
      activeShift: activeShift,
      shiftHistoryWeek: shiftHistoryWeek,
      shiftCoaching: shiftCoaching,
      shiftAnalytics: shiftAnalytics,
    );
  }

  static String? _lowestTakeRate(List<PlatformTripEntity> trips) {
    if (trips.isEmpty) return null;
    final byPlatform = <RidePlatform, double>{};
    final gross = <RidePlatform, double>{};
    for (final trip in trips.where((t) => t.isCompleted)) {
      gross[trip.platform] = (gross[trip.platform] ?? 0) + trip.grossAmount;
      byPlatform[trip.platform] =
          (byPlatform[trip.platform] ?? 0) + trip.platformFee;
    }
    RidePlatform? best;
    var bestRate = double.infinity;
    for (final entry in gross.entries) {
      final rate = entry.value > 0
          ? (byPlatform[entry.key] ?? 0) / entry.value * 100
          : 100.0;
      if (rate < bestRate) {
        bestRate = rate;
        best = entry.key;
      }
    }
    return best?.label;
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
      if (snapshot.platformBreakdown.isNotEmpty)
        'Receita por app: ${snapshot.platformBreakdown.map((s) => '${s.platform.label} ${s.amount.toStringAsFixed(0)}').join(', ')}',
      if (snapshot.platformTripCount > 0)
        'Corridas dos apps: ${snapshot.platformTripCount}',
      if (snapshot.lowestTakeRatePlatform != null)
        'Menor taxa de plataforma: ${snapshot.lowestTakeRatePlatform}',
      if (snapshot.platformConsistency.isNotEmpty)
        'Consistência: ${snapshot.platformConsistency.map((c) => '${c.platform.label} ${c.consistencyScore.round()}').join(', ')}',
      if (snapshot.platformTrendSummary.isNotEmpty)
        'Tendência 7d: ${snapshot.platformTrendSummary.map((p) => '${p.weekdayLabel} ${p.total.toStringAsFixed(0)}').join(', ')}',
      if (snapshot.platformNetProfit.isNotEmpty)
        'Lucro líquido por app: ${snapshot.platformNetProfit.map((n) => '${n.platform.label} ${n.netAmount.toStringAsFixed(0)}').join(', ')}',
      if (snapshot.platformProfitPerKm.isNotEmpty)
        'Lucro/km por app: ${snapshot.platformProfitPerKm.map((p) => '${p.platform.label} ${p.profitPerKm.toStringAsFixed(2)}').join(', ')}',
      if (snapshot.topHeatmapSlots.isNotEmpty)
        'Heatmap top slots: ${snapshot.topHeatmapSlots.map((h) => '${h.platform.label} ${h.weekdayLabel} ${h.hour}h ${h.revenuePerHour.toStringAsFixed(0)}/h').join('; ')}',
      if (snapshot.platformScores.isNotEmpty)
        'Score por app: ${snapshot.platformScores.map((s) => '${s.platform.label} ${s.score.round()}').join(', ')}',
      if (snapshot.activeShift != null)
        'Turno ativo: ${snapshot.activeShift}',
      if (snapshot.shiftHistoryWeek != null)
        'Turnos 7d: ${snapshot.shiftHistoryWeek}',
      if (snapshot.shiftCoaching != null)
        'Coaching turno: ${snapshot.shiftCoaching}',
      if (snapshot.shiftAnalytics != null)
        'Analytics turnos: ${snapshot.shiftAnalytics}',
    ].join('\n');
  }
}
