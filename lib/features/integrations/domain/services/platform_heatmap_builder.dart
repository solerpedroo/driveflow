import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/utils/iterable_extensions.dart';
import '../entities/platform_heatmap_slot.dart';
import '../entities/platform_trip_entity.dart';
import 'platform_analytics_breakdown.dart';
import 'platform_trip_duration.dart';

/// Heatmap 7×24 de R$/h por Uber, 99 e InDrive.
abstract final class PlatformHeatmapBuilder {
  static const lookbackDays = 60;

  static List<PlatformHeatmapSlot> build({
    required List<PlatformTripEntity> trips,
    RidePlatform? filterPlatform,
    DateTime? now,
  }) {
    final anchor = now ?? DateTime.now();
    final cutoff = anchor.subtract(const Duration(days: lookbackDays));
    final buckets = <String, _Bucket>{};

    for (final trip in trips) {
      if (!trip.isCompleted) continue;
      if (!PlatformAnalyticsBreakdown.integratable.contains(trip.platform)) {
        continue;
      }
      if (trip.startedAt.isBefore(cutoff)) continue;
      if (filterPlatform != null && trip.platform != filterPlatform) continue;

      final hours = PlatformTripDuration.workedHours(trip);
      _add(
        buckets,
        weekday: trip.startedAt.weekday,
        hour: trip.startedAt.hour,
        platform: trip.platform,
        revenue: trip.driverPayout,
        hours: hours,
      );
    }

    return buckets.values
        .map(
          (b) => PlatformHeatmapSlot(
            weekday: b.weekday,
            hour: b.hour,
            platform: b.platform,
            revenuePerHour: b.hours > 0 ? b.revenue / b.hours : 0,
            tripCount: b.count,
            totalRevenue: b.revenue,
          ),
        )
        .toList(growable: false)
      ..sort((a, b) => b.revenuePerHour.compareTo(a.revenuePerHour));
  }

  static PlatformHeatmapSlot? bestForNow({
    required List<PlatformTripEntity> trips,
    DateTime? now,
  }) {
    final anchor = now ?? DateTime.now();
    final slots = build(trips: trips, now: anchor);
    if (slots.isEmpty) return null;

    return slots
            .where(
              (s) => s.weekday == anchor.weekday && s.hour == anchor.hour,
            )
            .firstOrNull ??
        slots.first;
  }

  static void _add(
    Map<String, _Bucket> buckets, {
    required int weekday,
    required int hour,
    required RidePlatform platform,
    required double revenue,
    required double hours,
  }) {
    final key = '$weekday-$hour-${platform.value}';
    final existing = buckets[key];
    if (existing == null) {
      buckets[key] = _Bucket(
        weekday: weekday,
        hour: hour,
        platform: platform,
        revenue: revenue,
        hours: hours,
        count: 1,
      );
    } else {
      buckets[key] = existing.copyWith(
        revenue: existing.revenue + revenue,
        hours: existing.hours + hours,
        count: existing.count + 1,
      );
    }
  }
}

class _Bucket {
  const _Bucket({
    required this.weekday,
    required this.hour,
    required this.platform,
    required this.revenue,
    required this.hours,
    required this.count,
  });

  final int weekday;
  final int hour;
  final RidePlatform platform;
  final double revenue;
  final double hours;
  final int count;

  _Bucket copyWith({
    double? revenue,
    double? hours,
    int? count,
  }) {
    return _Bucket(
      weekday: weekday,
      hour: hour,
      platform: platform,
      revenue: revenue ?? this.revenue,
      hours: hours ?? this.hours,
      count: count ?? this.count,
    );
  }
}
