import '../../../../core/constants/ride_platforms.dart';
import '../entities/platform_efficiency_snapshot.dart';
import '../entities/platform_trip_entity.dart';

/// R$/corrida, R$/km e gorjeta média por plataforma.
abstract final class PlatformEfficiencyAnalyzer {
  static List<PlatformEfficiencySnapshot> analyze({
    required List<PlatformTripEntity> trips,
  }) {
    final byPlatform = <RidePlatform, List<PlatformTripEntity>>{};

    for (final trip in trips) {
      if (!trip.isCompleted) continue;
      byPlatform.putIfAbsent(trip.platform, () => []).add(trip);
    }

    return [
      for (final entry in byPlatform.entries) _snapshot(entry.key, entry.value),
    ]..sort((a, b) => b.avgPerRide.compareTo(a.avgPerRide));
  }

  static PlatformEfficiencySnapshot _snapshot(
    RidePlatform platform,
    List<PlatformTripEntity> trips,
  ) {
    final count = trips.length;
    final payout = trips.fold<double>(0, (s, t) => s + t.driverPayout);
    final tips = trips.fold<double>(0, (s, t) => s + t.tipAmount);
    final km = trips.fold<double>(0, (s, t) => s + (t.distanceKm ?? 0));
    final withKm = trips.where((t) => (t.distanceKm ?? 0) > 0).length;

    return PlatformEfficiencySnapshot(
      platform: platform,
      avgPerRide: count > 0 ? payout / count : 0,
      avgPerKm: km > 0 ? payout / km : 0,
      avgDistanceKm: withKm > 0 ? km / withKm : 0,
      avgTipPerRide: count > 0 ? tips / count : 0,
      tripCount: count,
    );
  }
}
