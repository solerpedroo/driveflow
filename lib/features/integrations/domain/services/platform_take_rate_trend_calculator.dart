import '../../../../core/utils/date_utils.dart';
import '../entities/platform_take_rate_point.dart';
import '../entities/platform_trip_entity.dart';

/// Série semanal de take rate e gorjetas por app.
abstract final class PlatformTakeRateTrendCalculator {
  static List<PlatformTakeRatePoint> build({
    required List<PlatformTripEntity> trips,
    int weeks = 8,
    DateTime? anchor,
  }) {
    final now = anchor ?? DateTime.now();
    final points = <PlatformTakeRatePoint>[];

    for (var w = weeks - 1; w >= 0; w--) {
      final weekStart = DateUtilsDriveFlow.startOfDay(
        now.subtract(Duration(days: w * 7 + now.weekday - 1)),
      );
      final weekEnd = weekStart.add(const Duration(days: 6, hours: 23, minutes: 59));

      final weekTrips = trips.where(
        (t) =>
            t.isCompleted &&
            !t.startedAt.isBefore(weekStart) &&
            !t.startedAt.isAfter(weekEnd),
      );

      final byPlatform = <RidePlatform, List<PlatformTripEntity>>{};
      for (final trip in weekTrips) {
        byPlatform.putIfAbsent(trip.platform, () => []).add(trip);
      }

      for (final entry in byPlatform.entries) {
        final gross = entry.value.fold<double>(0, (s, t) => s + t.grossAmount);
        final fees = entry.value.fold<double>(0, (s, t) => s + t.platformFee);
        final tips = entry.value.fold<double>(0, (s, t) => s + t.tipAmount);
        final count = entry.value.length;

        points.add(
          PlatformTakeRatePoint(
            weekStart: weekStart,
            platform: entry.key,
            takeRatePercent: gross > 0 ? (fees / gross) * 100 : 0,
            avgTipPerRide: count > 0 ? tips / count : 0,
            tripCount: count,
          ),
        );
      }
    }

    return points;
  }
}
