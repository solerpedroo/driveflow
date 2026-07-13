import '../../../../core/constants/ride_platforms.dart';
import 'shift_analytics_period.dart';
import 'shift_daily_point.dart';
import 'shift_history_entry.dart';
import 'shift_period_comparison.dart';

/// Resumo analítico dos turnos em uma janela de tempo.
class ShiftAnalyticsSummary {
  const ShiftAnalyticsSummary({
    required this.period,
    required this.shiftCount,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.totalNetCash,
    required this.totalRides,
    required this.avgRevenuePerHour,
    required this.avgAdherence,
    required this.avgDuration,
    required this.dailyPoints,
    required this.platformRevenue,
    this.comparison,
    this.bestRevenueShift,
  });

  final ShiftAnalyticsPeriod period;
  final int shiftCount;
  final double totalRevenue;
  final double totalExpenses;
  final double totalNetCash;
  final int totalRides;
  final double avgRevenuePerHour;
  final double avgAdherence;
  final Duration avgDuration;
  final List<ShiftDailyPoint> dailyPoints;
  final Map<RidePlatform, double> platformRevenue;
  final ShiftPeriodComparison? comparison;
  final ShiftHistoryEntry? bestRevenueShift;

  bool get isEmpty => shiftCount == 0;

  static ShiftAnalyticsSummary empty(ShiftAnalyticsPeriod period) {
    return ShiftAnalyticsSummary(
      period: period,
      shiftCount: 0,
      totalRevenue: 0,
      totalExpenses: 0,
      totalNetCash: 0,
      totalRides: 0,
      avgRevenuePerHour: 0,
      avgAdherence: 0,
      avgDuration: Duration.zero,
      dailyPoints: const [],
      platformRevenue: const {},
    );
  }

  Map<String, dynamic> toJson() => {
        'periodDays': period.days,
        'shiftCount': shiftCount,
        'totalRevenue': totalRevenue,
        'totalExpenses': totalExpenses,
        'totalNetCash': totalNetCash,
        'totalRides': totalRides,
        'avgRevenuePerHour': avgRevenuePerHour,
        'avgAdherence': avgAdherence,
        'avgDurationMinutes': avgDuration.inMinutes,
        'revenueDeltaPercent': comparison?.revenueDeltaPercent,
        'topPlatform': _topPlatformLabel(),
      };

  String? _topPlatformLabel() {
    if (platformRevenue.isEmpty) return null;
    return platformRevenue.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key
        .label;
  }
}
