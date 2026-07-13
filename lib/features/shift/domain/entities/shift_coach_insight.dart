import '../../../../core/constants/ride_platforms.dart';

/// Insight de coaching derivado dos turnos recentes.
class ShiftCoachInsight {
  const ShiftCoachInsight({
    required this.shiftsAnalyzed,
    required this.avgAdherence,
    required this.headline,
    required this.detail,
    required this.tips,
    this.preferredPlatform,
    this.typicalDeviationHour,
    this.typicalDeviationPlatform,
  });

  final int shiftsAnalyzed;
  final double avgAdherence;
  final String headline;
  final String detail;
  final List<String> tips;
  final RidePlatform? preferredPlatform;
  final int? typicalDeviationHour;
  final RidePlatform? typicalDeviationPlatform;

  bool get hasData => shiftsAnalyzed > 0;

  Map<String, dynamic> toJson() => {
        'shiftsAnalyzed': shiftsAnalyzed,
        'avgAdherence': avgAdherence,
        'headline': headline,
        'detail': detail,
        'tips': tips,
        'preferredPlatform': preferredPlatform?.value,
        'typicalDeviationHour': typicalDeviationHour,
        'typicalDeviationPlatform': typicalDeviationPlatform?.value,
      };
}
