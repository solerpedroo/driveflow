import '../../../earnings/domain/entities/earning_entity.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../entities/shift_session_entity.dart';
import '../entities/shift_session_summary.dart';
import '../../../../core/constants/ride_platforms.dart';
import 'shift_net_cash_calculator.dart';

/// Agrega ganhos e métricas dentro da janela da sessão.
abstract final class ShiftSessionAggregator {
  static List<EarningEntity> earningsInSession({
    required ShiftSessionEntity session,
    required List<EarningEntity> earnings,
    String? vehicleId,
  }) {
    return earnings.where((earning) {
      if (vehicleId != null && earning.vehicleId != vehicleId) return false;
      final anchor = earning.createdAt ?? earning.date;
      return !anchor.isBefore(session.startedAt) &&
          (session.endedAt == null || anchor.isBefore(session.endedAt!));
    }).toList(growable: false);
  }

  static ShiftSessionSummary summarize({
    required ShiftSessionEntity session,
    required List<EarningEntity> earnings,
    required DateTime now,
    double dailyGoal = 0,
    String? vehicleId,
    List<ExpenseEntity> expenses = const [],
  }) {
    final scoped = earningsInSession(
      session: session,
      earnings: earnings,
      vehicleId: vehicleId ?? session.vehicleId,
    );
    final revenue = scoped.fold<double>(0, (sum, e) => sum + e.amount);
    final rides = scoped.fold<int>(0, (sum, e) => sum + e.rides);
    final elapsed = session.elapsedAt(now);
    final hours = elapsed.inSeconds / 3600;
    final revenuePerHour = hours >= 0.05 ? revenue / hours : null;

    RidePlatform? topPlatform;
    if (scoped.isNotEmpty) {
      final totals = <RidePlatform, double>{};
      for (final earning in scoped) {
        totals[earning.platform] =
            (totals[earning.platform] ?? 0) + earning.amount;
      }
      topPlatform = totals.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
    }

    final goalProgress =
        dailyGoal > 0 ? (revenue / dailyGoal).clamp(0.0, 1.5) : 0.0;

    final scopedExpenses = ShiftNetCashCalculator.expensesInSession(
      session: session,
      expenses: expenses,
      vehicleId: vehicleId ?? session.vehicleId,
    );
    final netCash = ShiftNetCashCalculator.compute(
      revenue: revenue,
      elapsed: elapsed,
      scopedExpenses: scopedExpenses,
    );

    return ShiftSessionSummary(
      elapsed: elapsed,
      revenue: revenue,
      rides: rides,
      revenuePerHour: revenuePerHour,
      goalProgress: goalProgress,
      topPlatform: topPlatform,
      expenses: netCash.expenses,
      netCash: netCash.netCash,
      netPerHour: netCash.netPerHour,
    );
  }
}
