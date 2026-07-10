import '../../../../core/constants/ride_platforms.dart';

/// Métricas de eficiência por corrida e por km.
class PlatformEfficiencySnapshot {
  const PlatformEfficiencySnapshot({
    required this.platform,
    required this.avgPerRide,
    required this.avgPerKm,
    required this.avgDistanceKm,
    required this.avgTipPerRide,
    required this.tripCount,
  });

  final RidePlatform platform;
  final double avgPerRide;
  final double avgPerKm;
  final double avgDistanceKm;
  final double avgTipPerRide;
  final int tripCount;

  bool get hasData => tripCount > 0;
}
