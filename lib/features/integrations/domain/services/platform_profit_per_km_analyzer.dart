import '../../../../core/constants/ride_platforms.dart';
import '../entities/platform_trip_entity.dart';

/// Lucro líquido por km rodado em uma plataforma.
class PlatformProfitPerKmSnapshot {
  const PlatformProfitPerKmSnapshot({
    required this.platform,
    required this.totalKm,
    required this.netProfit,
    required this.profitPerKm,
    required this.tripCount,
  });

  final RidePlatform platform;
  final double totalKm;
  final double netProfit;
  final double profitPerKm;
  final int tripCount;

  bool get hasData => totalKm > 0;
}

/// Cruza corridas sincronizadas com custo/km de combustível.
abstract final class PlatformProfitPerKmAnalyzer {
  static List<PlatformProfitPerKmSnapshot> analyze({
    required List<PlatformTripEntity> trips,
    required double fuelCostPerKm,
  }) {
    if (fuelCostPerKm <= 0) return const [];

    final byPlatform = <RidePlatform, List<PlatformTripEntity>>{};
    for (final trip in trips) {
      if (!trip.isCompleted || trip.distanceKm == null || trip.distanceKm! <= 0) {
        continue;
      }
      byPlatform.putIfAbsent(trip.platform, () => []).add(trip);
    }

    return [
      for (final entry in byPlatform.entries) _snapshot(entry.key, entry.value, fuelCostPerKm),
    ]..sort((a, b) => b.profitPerKm.compareTo(a.profitPerKm));
  }

  static PlatformProfitPerKmSnapshot _snapshot(
    RidePlatform platform,
    List<PlatformTripEntity> trips,
    double fuelCostPerKm,
  ) {
    final totalKm = trips.fold<double>(0, (sum, t) => sum + (t.distanceKm ?? 0));
    final payout = trips.fold<double>(0, (sum, t) => sum + t.driverPayout);
    final fuelCost = totalKm * fuelCostPerKm;
    final net = payout - fuelCost;

    return PlatformProfitPerKmSnapshot(
      platform: platform,
      totalKm: totalKm,
      netProfit: net,
      profitPerKm: totalKm > 0 ? net / totalKm : 0,
      tripCount: trips.length,
    );
  }
}
