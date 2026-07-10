import '../../../../core/constants/ride_platforms.dart';

/// Resultado da simulação de mix entre apps.
class PlatformMixSimulation {
  const PlatformMixSimulation({
    required this.mixPercent,
    required this.projectedMonthlyProfit,
    required this.projectedMonthlyRevenue,
    required this.bestPlatform,
  });

  /// Percentual 0–100 por plataforma (soma = 100).
  final Map<RidePlatform, double> mixPercent;
  final double projectedMonthlyProfit;
  final double projectedMonthlyRevenue;
  final RidePlatform bestPlatform;
}
