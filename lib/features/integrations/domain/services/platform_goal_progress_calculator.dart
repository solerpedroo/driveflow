import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../earnings/domain/entities/earning_entity.dart';
import '../../../goals/domain/entities/goal_entity.dart';
import '../entities/platform_goal_progress.dart';
import '../entities/platform_trip_entity.dart';
import 'platform_analytics_breakdown.dart';

/// Divide meta diária pelo share histórico de cada app.
abstract final class PlatformGoalProgressCalculator {
  static const integratable = PlatformAnalyticsBreakdown.integratable;

  static List<PlatformGoalProgress> calculate({
    required GoalEntity? goals,
    required List<EarningEntity> earnings,
    required List<PlatformTripEntity> trips,
    DateTime? now,
  }) {
    final dailyTarget = goals?.daily ?? 0;
    if (dailyTarget <= 0) return const [];

    final anchor = now ?? DateTime.now();
    final todayByPlatform = _todayActualByPlatform(
      earnings: earnings,
      trips: trips,
      anchor: anchor,
    );

    final historical = PlatformAnalyticsBreakdown.fromEarnings(earnings);
    final totalHistorical =
        historical.fold<double>(0, (s, slice) => s + slice.amount);

    final results = <PlatformGoalProgress>[];

    for (final platform in integratable) {
      final slice = historical
          .where((s) => s.platform == platform)
          .firstOrNull;
      final share = totalHistorical > 0
          ? (slice?.sharePercent ?? 0) / 100
          : 1 / integratable.length;
      final target = dailyTarget * share;
      final actual = todayByPlatform[platform] ?? 0;
      final percent = target > 0 ? (actual / target) * 100 : 0;

      if (share > 0 || actual > 0) {
        results.add(
          PlatformGoalProgress(
            platform: platform,
            targetAmount: target,
            actualAmount: actual,
            progressPercent: percent.clamp(0, 999),
            sharePercent: share * 100,
          ),
        );
      }
    }

    return results..sort((a, b) => b.actualAmount.compareTo(a.actualAmount));
  }

  /// Corridas do dia têm prioridade; evita duplicar rollup `api_sync`.
  static Map<RidePlatform, double> _todayActualByPlatform({
    required List<EarningEntity> earnings,
    required List<PlatformTripEntity> trips,
    required DateTime anchor,
  }) {
    final todayStart = DateUtilsDriveFlow.startOfDay(anchor);
    final todayEnd = DateUtilsDriveFlow.endOfDay(anchor);
    final result = <RidePlatform, double>{};

    for (final trip in trips) {
      if (!trip.isCompleted || !integratable.contains(trip.platform)) continue;
      if (trip.startedAt.isBefore(todayStart) ||
          trip.startedAt.isAfter(todayEnd)) {
        continue;
      }
      result[trip.platform] =
          (result[trip.platform] ?? 0) + trip.driverPayout;
    }

    for (final earning in earnings) {
      if (!integratable.contains(earning.platform)) continue;
      if (earning.date.isBefore(todayStart) || earning.date.isAfter(todayEnd)) {
        continue;
      }
      final tripSum = result[earning.platform] ?? 0;
      if (tripSum > 0) continue;
      result[earning.platform] =
          (result[earning.platform] ?? 0) + earning.amount;
    }

    return result;
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
