import '../../../../core/constants/ride_platforms.dart';
import '../entities/platform_mix_simulation.dart';
import '../entities/platform_net_profit_slice.dart';

/// Projeta lucro mensal com base no mix Uber/99/InDrive.
abstract final class PlatformMixSimulator {
  static const integratable = {
    RidePlatform.uber,
    RidePlatform.ninetyNine,
    RidePlatform.inDrive,
  };

  static PlatformMixSimulation simulate({
    required Map<RidePlatform, double> mixPercent,
    required List<PlatformNetProfitSlice> netSlices,
    int workingDaysPerMonth = 22,
    double hoursPerDay = 8,
  }) {
    final normalized = _normalize(mixPercent);
    final profitPerHour = <RidePlatform, double>{};
    final revenuePerHour = <RidePlatform, double>{};

    for (final slice in netSlices) {
      if (!integratable.contains(slice.platform)) continue;
      if (slice.workedHours <= 0) continue;

      profitPerHour[slice.platform] = slice.netAmount / slice.workedHours;
      revenuePerHour[slice.platform] = slice.grossAmount / slice.workedHours;
    }

    var projectedProfit = 0.0;
    var projectedRevenue = 0.0;
    RidePlatform? best;
    var bestRate = 0.0;

    for (final platform in integratable) {
      final share = (normalized[platform] ?? 0) / 100;
      final profitRate = profitPerHour[platform] ?? 0;
      final revenueRate = revenuePerHour[platform] ?? 0;

      projectedProfit +=
          profitRate * hoursPerDay * workingDaysPerMonth * share;
      projectedRevenue +=
          revenueRate * hoursPerDay * workingDaysPerMonth * share;

      if (profitRate > bestRate) {
        bestRate = profitRate;
        best = platform;
      }
    }

    return PlatformMixSimulation(
      mixPercent: normalized,
      projectedMonthlyProfit: projectedProfit,
      projectedMonthlyRevenue: projectedRevenue,
      bestPlatform: best ?? RidePlatform.uber,
    );
  }

  static Map<RidePlatform, double> _normalize(
    Map<RidePlatform, double> mix,
  ) {
    final filtered = {
      for (final p in integratable) p: (mix[p] ?? 0).clamp(0, 100),
    };
    final total = filtered.values.fold<double>(0, (s, v) => s + v);
    if (total <= 0) {
      return {for (final p in integratable) p: 100 / integratable.length};
    }
    return {
      for (final entry in filtered.entries)
        entry.key: (entry.value / total) * 100,
    };
  }
}
