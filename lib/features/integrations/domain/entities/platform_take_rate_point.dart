import '../../../../core/constants/ride_platforms.dart';

/// Ponto semanal de take rate por plataforma.
class PlatformTakeRatePoint {
  const PlatformTakeRatePoint({
    required this.weekStart,
    required this.platform,
    required this.takeRatePercent,
    required this.avgTipPerRide,
    required this.tripCount,
  });

  final DateTime weekStart;
  final RidePlatform platform;
  final double takeRatePercent;
  final double avgTipPerRide;
  final int tripCount;
}
