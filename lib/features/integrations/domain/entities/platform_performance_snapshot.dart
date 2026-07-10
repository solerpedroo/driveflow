import '../../../../core/constants/ride_platforms.dart';

/// Snapshot de desempenho financeiro por plataforma.
class PlatformPerformanceSnapshot {
  const PlatformPerformanceSnapshot({
    required this.platform,
    required this.totalAmount,
    required this.totalRides,
    required this.totalHours,
    required this.avgPerRide,
    required this.avgPerHour,
    required this.sharePercent,
  });

  final RidePlatform platform;
  final double totalAmount;
  final int totalRides;
  final double totalHours;
  final double avgPerRide;
  final double avgPerHour;
  final double sharePercent;

  bool get hasData => totalAmount > 0 || totalRides > 0;
}
