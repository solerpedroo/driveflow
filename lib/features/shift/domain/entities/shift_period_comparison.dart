/// Comparação do período atual com o anterior (mesma duração).
class ShiftPeriodComparison {
  const ShiftPeriodComparison({
    required this.currentRevenue,
    required this.previousRevenue,
    required this.currentShifts,
    required this.previousShifts,
    required this.currentAvgAdherence,
    required this.previousAvgAdherence,
  });

  final double currentRevenue;
  final double previousRevenue;
  final int currentShifts;
  final int previousShifts;
  final double currentAvgAdherence;
  final double previousAvgAdherence;

  double? get revenueDeltaPercent {
    if (previousRevenue <= 0) return null;
    return ((currentRevenue - previousRevenue) / previousRevenue) * 100;
  }

  int get shiftDelta => currentShifts - previousShifts;

  double get adherenceDelta => currentAvgAdherence - previousAvgAdherence;
}
