import '../entities/platform_region_snapshot.dart';
import '../entities/platform_trip_entity.dart';

/// Top regiões por R$/corrida a partir de pickup_label.
abstract final class PlatformRegionAnalyzer {
  static const maxRegions = 5;

  static List<PlatformRegionSnapshot> topRegions({
    required List<PlatformTripEntity> trips,
    int limit = maxRegions,
  }) {
    final grouped = <String, _RegionGroup>{};

    for (final trip in trips) {
      if (!trip.isCompleted) continue;
      final label = _normalizeRegion(trip.pickupLabel);
      if (label.isEmpty) continue;

      final key = '${trip.platform.value}-$label';
      final existing = grouped[key];
      if (existing == null) {
        grouped[key] = _RegionGroup(
          platform: trip.platform,
          label: label,
          payout: trip.driverPayout,
          count: 1,
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
          ),
        )
        .toList()
      ..sort((a, b) => b.avgPayout.compareTo(a.avgPayout));

    return sorted.take(limit).toList(growable: false);
  }

  static String _normalizeRegion(String? label) {
    if (label == null || label.trim().isEmpty) return '';
    final trimmed = label.trim();
    final comma = trimmed.indexOf(',');
    if (comma > 0) return trimmed.substring(0, comma).trim();
    final parts = trimmed.split(' ');
    return parts.take(2).join(' ');
  }
}

class _RegionGroup {
  const _RegionGroup({
    required this.platform,
    required this.label,
    required this.payout,
    required this.count,
  });

  final RidePlatform platform;
  final String label;
  final double payout;
  final int count;

  _RegionGroup copyWith({double? payout, int? count}) {
    return _RegionGroup(
      platform: platform,
      label: label,
      payout: payout ?? this.payout,
      count: count ?? this.count,
    );
  }
}
