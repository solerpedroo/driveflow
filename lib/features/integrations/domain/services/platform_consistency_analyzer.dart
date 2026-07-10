import 'dart:math' as math;

import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/utils/date_utils.dart';
import '../entities/platform_consistency_snapshot.dart';
import '../entities/platform_trip_entity.dart';

/// Score de consistência (menor volatilidade = maior score).
abstract final class PlatformConsistencyAnalyzer {
  static List<PlatformConsistencySnapshot> analyze({
    required List<PlatformTripEntity> trips,
    int lookbackDays = 30,
    DateTime? now,
  }) {
    final anchor = now ?? DateTime.now();
    final cutoff = anchor.subtract(Duration(days: lookbackDays));
    final daily = <RidePlatform, Map<DateTime, double>>{};

    for (final trip in trips) {
      if (!trip.isCompleted) continue;
      if (trip.startedAt.isBefore(cutoff)) continue;

      final day = DateUtilsDriveFlow.startOfDay(trip.startedAt);
      daily.putIfAbsent(trip.platform, () => {});
      daily[trip.platform]![day] =
          (daily[trip.platform]![day] ?? 0) + trip.driverPayout;
    }

    return [
      for (final entry in daily.entries) _snapshot(entry.key, entry.value),
    ]..sort((a, b) => b.consistencyScore.compareTo(a.consistencyScore));
  }

  static PlatformConsistencySnapshot _snapshot(
    RidePlatform platform,
    Map<DateTime, double> dailyProfits,
  ) {
    final values = dailyProfits.values.toList();
    if (values.isEmpty) {
      return PlatformConsistencySnapshot(
        platform: platform,
        avgDailyProfit: 0,
        stdDevDailyProfit: 0,
        consistencyScore: 0,
        activeDays: 0,
      );
    }

    final avg = values.fold<double>(0, (s, v) => s + v) / values.length;
    final variance = values.fold<double>(
          0,
          (s, v) => s + math.pow(v - avg, 2),
        ) /
        values.length;
    final stdDev = math.sqrt(variance);
    final cv = avg > 0 ? stdDev / avg : 1;
    final score = (100 - (cv * 100)).clamp(0, 100);

    return PlatformConsistencySnapshot(
      platform: platform,
      avgDailyProfit: avg,
      stdDevDailyProfit: stdDev,
      consistencyScore: score.toDouble(),
      activeDays: values.length,
    );
  }
}
