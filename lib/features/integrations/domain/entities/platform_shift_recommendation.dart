import '../../../../core/constants/ride_platforms.dart';

/// Recomendação de qual app abrir em um turno.
class PlatformShiftRecommendation {
  const PlatformShiftRecommendation({
    required this.recommended,
    required this.reason,
    required this.confidence,
    required this.alternatives,
    this.bestHourSlot,
  });

  final RidePlatform recommended;
  final String reason;
  final double confidence;
  final List<PlatformPerformanceSnapshot> alternatives;
  final String? bestHourSlot;
}
