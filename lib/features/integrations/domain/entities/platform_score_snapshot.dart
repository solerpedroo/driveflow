import '../../../../core/constants/ride_platforms.dart';

/// Nota composta de uma plataforma para o motorista.
class PlatformScoreSnapshot {
  const PlatformScoreSnapshot({
    required this.platform,
    required this.score,
    required this.avgPerHour,
    required this.takeRatePercent,
    required this.tripCount,
    required this.consistencyPercent,
    required this.label,
  });

  final RidePlatform platform;
  final double score;
  final double avgPerHour;
  final double takeRatePercent;
  final int tripCount;
  final double consistencyPercent;
  final String label;
}
