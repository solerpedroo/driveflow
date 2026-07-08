/// Projeção de atingimento da meta semanal.
class WeeklyGoalProjection {
  const WeeklyGoalProjection({
    required this.targetAmount,
    required this.actualProfit,
    required this.projectedProfit,
    required this.daysElapsed,
    required this.daysRemaining,
    required this.hasTarget,
  });

  final double targetAmount;
  final double actualProfit;
  final double projectedProfit;
  final int daysElapsed;
  final int daysRemaining;
  final bool hasTarget;

  double get progressPercent =>
      hasTarget && targetAmount > 0
          ? (actualProfit / targetAmount * 100).clamp(0, 999)
          : 0;

  bool get onTrack => hasTarget && projectedProfit >= targetAmount;
}
