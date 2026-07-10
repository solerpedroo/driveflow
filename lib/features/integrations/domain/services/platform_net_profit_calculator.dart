import '../../../../core/constants/ride_platforms.dart';
import '../entities/platform_net_profit_slice.dart';
import '../entities/platform_trip_entity.dart';
import 'platform_analytics_breakdown.dart';

/// Lucro líquido por app: payout − custo combustível estimado.
abstract final class PlatformNetProfitCalculator {
  static List<PlatformNetProfitSlice> fromTrips({
    required List<PlatformTripEntity> trips,
    required double fuelCostPerKm,
  }) {
    final byPlatform = <RidePlatform, List<PlatformTripEntity>>{};

    for (final trip in trips) {
      if (!trip.isCompleted || !PlatformAnalyticsBreakdown.integratable.contains(trip.platform)) {
        continue;
      }
      byPlatform.putIfAbsent(trip.platform, () => []).add(trip);
    }

    return [
      for (final entry in byPlatform.entries)
        _slice(entry.key, entry.value, fuelCostPerKm),
    ]..sort((a, b) => b.netAmount.compareTo(a.netAmount));
  }

  static PlatformNetProfitSlice _slice(
    RidePlatform platform,
    List<PlatformTripEntity> trips,
    double fuelCostPerKm,
  ) {
    final gross = trips.fold<double>(0, (s, t) => s + t.grossAmount);
    final fees = trips.fold<double>(0, (s, t) => s + t.platformFee);
    final payout = trips.fold<double>(0, (s, t) => s + t.driverPayout);
    final km = trips.fold<double>(
      0,
      (s, t) => s + (t.distanceKm ?? 0),
    );
    final fuelCost = km * fuelCostPerKm;

    return PlatformNetProfitSlice(
      platform: platform,
      grossAmount: gross,
      platformFees: fees,
      fuelCost: fuelCost,
      netAmount: payout - fuelCost,
      tripCount: trips.length,
    );
  }
}
