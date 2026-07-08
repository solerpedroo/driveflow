import '../entities/goal_entity.dart';

/// Resultado do progresso de uma meta financeira.
class GoalProgress {
  const GoalProgress({
    required this.period,
    required this.targetAmount,
    required this.actualProfit,
    required this.progressPercent,
    required this.remainingAmount,
    required this.hasTarget,
  });

  final GoalPeriod period;
  final double targetAmount;
  final double actualProfit;
  final double progressPercent;
  final double remainingAmount;
  final bool hasTarget;

  bool get isComplete => hasTarget && actualProfit >= targetAmount;

  String get progressLabel =>
      hasTarget ? '${progressPercent.toStringAsFixed(0)}%' : '—';
}

/// Calcula lucro vs meta para um período.
abstract final class GoalProgressCalculator {
  static GoalProgress calculate({
    required GoalPeriod period,
    required GoalEntity? goals,
    required double earningsTotal,
    required double expensesTotal,
  }) {
    final target = goals?.amountFor(period) ?? 0;
    final profit = earningsTotal - expensesTotal;

    if (target <= 0) {
      return GoalProgress(
        period: period,
        targetAmount: 0,
        actualProfit: profit,
        progressPercent: 0,
        remainingAmount: 0,
        hasTarget: false,
      );
    }

    final percent = (profit / target * 100).clamp(0.0, 999.0);
    final remaining = (target - profit).clamp(0.0, double.infinity);

    return GoalProgress(
      period: period,
      targetAmount: target,
      actualProfit: profit,
      progressPercent: percent,
      remainingAmount: remaining,
      hasTarget: true,
    );
  }
}
