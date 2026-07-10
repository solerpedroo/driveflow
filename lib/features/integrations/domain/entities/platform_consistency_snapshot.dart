import '../../../../core/constants/ride_platforms.dart';

/// Estabilidade de lucro diário por plataforma.
class PlatformConsistencySnapshot {
  const PlatformConsistencySnapshot({
    required this.platform,
    required this.avgDailyProfit,
    required this.stdDevDailyProfit,
    required this.consistencyScore,
    required this.activeDays,
  });

  final RidePlatform platform;
  final double avgDailyProfit;
  final double stdDevDailyProfit;
  final double consistencyScore;
  final int activeDays;

  bool get isStable => consistencyScore >= 70;
}
