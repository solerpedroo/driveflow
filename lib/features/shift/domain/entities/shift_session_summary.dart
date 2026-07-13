import '../../../../core/constants/ride_platforms.dart';

/// Métricas ao vivo de uma sessão de turno.
class ShiftSessionSummary {
  const ShiftSessionSummary({
    required this.elapsed,
    required this.revenue,
    required this.rides,
    required this.revenuePerHour,
    required this.goalProgress,
    this.topPlatform,
    this.expenses = 0,
    this.netCash = 0,
    this.netPerHour,
  });

  final Duration elapsed;
  final double revenue;
  final int rides;
  final double? revenuePerHour;
  final double goalProgress;
  final RidePlatform? topPlatform;
  final double expenses;
  final double netCash;
  final double? netPerHour;

  bool get hasNetCashTracking => expenses > 0;

  static const empty = ShiftSessionSummary(
    elapsed: Duration.zero,
    revenue: 0,
    rides: 0,
    revenuePerHour: null,
    goalProgress: 0,
  );
}
