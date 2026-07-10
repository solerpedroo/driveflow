import '../../../../core/constants/ride_platforms.dart';
import '../entities/platform_region_snapshot.dart';
import '../entities/platform_trip_entity.dart';
import 'platform_analytics_breakdown.dart';
import 'platform_region_label.dart';

/// Top regiões por R$/corrida a partir de pickup/dropoff/distância.
abstract final class PlatformRegionAnalyzer {
  static const maxRegions = 5;

  static List<PlatformRegionSnapshot> topRegions({
    required List<PlatformTripEntity> trips,
    int limit = maxRegions,
  }) {
    final grouped = <String, _RegionGroup>{};

    for (final trip in trips) {
      if (!trip.isCompleted) continue;
      if (!PlatformAnalyticsBreakdown.integratable.contains(trip.platform)) {
        continue;
      }

      final label = PlatformRegionLabel.fromTrip(trip);
      final key = '${trip.platform.value}-$label';
      final existing = grouped[key];
      if (existing == null) {
        grouped[key] = _RegionGroup(
          platform: trip.platform,
          label: label,
          payout: trip.driverPayout,
          count: 1,
          isEstimated: PlatformRegionLabel.isEstimated(label),
        );
      } else {
        grouped[key] = existing.copyWith(
          payout: existing.payout + trip.driverPayout,
          count: existing.count + 1,
        );
      }
    }

    final sorted = grouped.values
        .map(
          (g) => PlatformRegionSnapshot(
            platform: g.platform,
            regionLabel: g.label,
            avgPayout: g.count > 0 ? g.payout / g.count : 0,
            tripCount: g.count,
            totalPayout: g.payout,
            isEstimated: g.isEstimated,
          ),
        )
        .toList()
      ..sort((a, b) {
        // Prefer endereços reais sobre buckets estimados.
        if (a.isEstimated != b.isEstimated) {
          return a.isEstimated ? 1 : -1;
        }
        return b.avgPayout.compareTo(a.avgPayout);
      });

    return sorted.take(limit).toList(growable: false);
  }
}

class _RegionGroup {
  const _RegionGroup({
    required this.platform,
    required this.label,
    required this.payout,
    required this.count,
    required this.isEstimated,
  });

  final RidePlatform platform;
  final String label;
  final double payout;
  final int count;
  final bool isEstimated;

  _RegionGroup copyWith({double? payout, int? count}) {
    return _RegionGroup(
      platform: platform,
      label: label,
      payout: payout ?? this.payout,
      count: count ?? this.count,
      isEstimated: isEstimated,
    );
  }
}
