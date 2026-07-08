import 'daily_profit_point.dart';
import 'period_summary.dart';

/// Snapshot consolidado do dashboard (hoje, semana, mês).
class DashboardSnapshot {
  const DashboardSnapshot({
    required this.today,
    required this.month,
    required this.weekProfits,
  });

  final PeriodSummary today;
  final PeriodSummary month;
  final List<DailyProfitPoint> weekProfits;
}
