import '../../../../core/constants/ride_platforms.dart';
import '../entities/shift_analytics_period.dart';
import '../entities/shift_analytics_summary.dart';
import '../entities/shift_daily_point.dart';
import '../entities/shift_history_entry.dart';
import '../entities/shift_period_comparison.dart';

/// Agrega histórico de turnos em métricas e séries para analytics.
abstract final class ShiftAnalyticsCalculator {
  static ShiftAnalyticsSummary calculate({
    required List<ShiftHistoryEntry> history,
    required ShiftAnalyticsPeriod period,
    DateTime? anchor,
  }) {
    final now = anchor ?? DateTime.now();
    final periodStart = _dayStart(now).subtract(Duration(days: period.days - 1));
    final previousStart =
        periodStart.subtract(Duration(days: period.days));

    final current = history
        .where((entry) => !_isBeforeDay(entry.startedAt, periodStart))
        .toList(growable: false);
    final previous = history
        .where(
          (entry) =>
              !_isBeforeDay(entry.startedAt, previousStart) &&
              _isBeforeDay(entry.startedAt, periodStart),
        )
        .toList(growable: false);

    if (current.isEmpty) return ShiftAnalyticsSummary.empty(period);

    final totalRevenue =
        current.fold<double>(0, (sum, entry) => sum + entry.revenue);
    final totalRides =
        current.fold<int>(0, (sum, entry) => sum + entry.rides);
    final avgAdherence = current.fold<double>(
          0,
          (sum, entry) => sum + entry.adherenceScore,
        ) /
        current.length;
    final totalElapsed = current.fold<Duration>(
      Duration.zero,
      (sum, entry) => sum + entry.elapsed,
    );
    final avgDuration = Duration(
      milliseconds: totalElapsed.inMilliseconds ~/ current.length,
    );

    final rphValues = current
        .map((entry) => entry.revenuePerHour)
        .whereType<double>()
        .where((value) => value > 0)
        .toList(growable: false);
    final avgRevenuePerHour = rphValues.isEmpty
        ? 0.0
        : rphValues.fold<double>(0, (sum, value) => sum + value) /
            rphValues.length;

    final platformRevenue = <RidePlatform, double>{};
    for (final entry in current) {
      entry.revenueByPlatform.forEach((platform, amount) {
        platformRevenue[platform] = (platformRevenue[platform] ?? 0) + amount;
      });
    }

    final dailyPoints = _dailyPoints(
      entries: current,
      periodStart: periodStart,
      periodDays: period.days,
    );

    final comparison = previous.isEmpty
        ? null
        : ShiftPeriodComparison(
            currentRevenue: totalRevenue,
            previousRevenue: previous.fold<double>(
              0,
              (sum, entry) => sum + entry.revenue,
            ),
            currentShifts: current.length,
            previousShifts: previous.length,
            currentAvgAdherence: avgAdherence,
            previousAvgAdherence: previous.fold<double>(
                  0,
                  (sum, entry) => sum + entry.adherenceScore,
                ) /
                previous.length,
          );

    ShiftHistoryEntry? bestRevenueShift;
    for (final entry in current) {
      if (bestRevenueShift == null ||
          entry.revenue > bestRevenueShift.revenue) {
        bestRevenueShift = entry;
      }
    }

    return ShiftAnalyticsSummary(
      period: period,
      shiftCount: current.length,
      totalRevenue: totalRevenue,
      totalRides: totalRides,
      avgRevenuePerHour: avgRevenuePerHour,
      avgAdherence: avgAdherence,
      avgDuration: avgDuration,
      dailyPoints: dailyPoints,
      platformRevenue: platformRevenue,
      comparison: comparison,
      bestRevenueShift: bestRevenueShift,
    );
  }

  static List<ShiftDailyPoint> _dailyPoints({
    required List<ShiftHistoryEntry> entries,
    required DateTime periodStart,
    required int periodDays,
  }) {
    final buckets = <DateTime, List<ShiftHistoryEntry>>{};
    for (var i = 0; i < periodDays; i++) {
      final day = periodStart.add(Duration(days: i));
      buckets[_dayStart(day)] = [];
    }

    for (final entry in entries) {
      final key = _dayStart(entry.startedAt);
      buckets.putIfAbsent(key, () => []).add(entry);
    }

    final points = buckets.entries.map((bucket) {
      final dayEntries = bucket.value;
      if (dayEntries.isEmpty) {
        return ShiftDailyPoint(
          date: bucket.key,
          revenue: 0,
          shiftCount: 0,
          avgAdherence: 0,
          revenuePerHour: 0,
        );
      }

      final revenue =
          dayEntries.fold<double>(0, (sum, entry) => sum + entry.revenue);
      final adherence = dayEntries.fold<double>(
            0,
            (sum, entry) => sum + entry.adherenceScore,
          ) /
          dayEntries.length;
      final rph = dayEntries
          .map((entry) => entry.revenuePerHour)
          .whereType<double>()
          .where((value) => value > 0)
          .toList(growable: false);
      final avgRph = rph.isEmpty
          ? 0.0
          : rph.fold<double>(0, (sum, value) => sum + value) / rph.length;

      return ShiftDailyPoint(
        date: bucket.key,
        revenue: revenue,
        shiftCount: dayEntries.length,
        avgAdherence: adherence,
        revenuePerHour: avgRph,
      );
    }).toList(growable: false)
      ..sort((a, b) => a.date.compareTo(b.date));

    return points;
  }

  static DateTime _dayStart(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static bool _isBeforeDay(DateTime value, DateTime dayStart) =>
      _dayStart(value).isBefore(dayStart);
}
