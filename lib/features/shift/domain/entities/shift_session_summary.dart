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
  });

  final Duration elapsed;
  final double revenue;
  final int rides;
  final double? revenuePerHour;
  final double goalProgress;
  final RidePlatform? topPlatform;

  static const empty = ShiftSessionSummary(
    elapsed: Duration.zero,
    revenue: 0,
    rides: 0,
    revenuePerHour: null,
    goalProgress: 0,
  );
}
