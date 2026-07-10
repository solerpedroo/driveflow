import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../earnings/domain/entities/earning_entity.dart';
import '../entities/platform_revenue_trend_point.dart';
import '../entities/platform_trip_entity.dart';

/// Série temporal de receita por Uber, 99 e InDrive.
abstract final class PlatformRevenueTrendCalculator {
  static const integratable = {
    RidePlatform.uber,
    RidePlatform.ninetyNine,
    RidePlatform.inDrive,
  };

  static List<PlatformRevenueTrendPoint> fromEarnings({
    required List<EarningEntity> earnings,
    int days = 30,
    DateTime? anchor,
  }) {
    final now = anchor ?? DateTime.now();
    return _buildSeries(
      days: days,
      anchor: now,
      amountForDay: (day) => _earningsByPlatform(earnings, day),
    );
  }

  static List<PlatformRevenueTrendPoint> fromTrips({
    required List<PlatformTripEntity> trips,
    int days = 30,
    DateTime? anchor,
  }) {
    final now = anchor ?? DateTime.now();
    return _buildSeries(
      days: days,
      anchor: now,
      amountForDay: (day) => _tripsByPlatform(trips, day),
    );
  }

  static List<PlatformRevenueTrendPoint> _buildSeries({
    required int days,
    required DateTime anchor,
    required Map<RidePlatform, double> Function(DateTime day) amountForDay,
  }) {
    final points = <PlatformRevenueTrendPoint>[];

    for (var i = 0; i < days; i++) {
      final day = DateUtilsDriveFlow.startOfDay(
        anchor.subtract(Duration(days: days - 1 - i)),
      );
      final amounts = amountForDay(day);
      final total = amounts.values.fold<double>(0, (s, v) => s + v);
      points.add(
        PlatformRevenueTrendPoint(
          date: day,
          amountsByPlatform: amounts,
          total: total,
        ),
      );
    }

    return _withDeltas(points);
  }

  static Map<RidePlatform, double> _earningsByPlatform(
    List<EarningEntity> earnings,
    DateTime day,
  ) {
    final start = DateUtilsDriveFlow.startOfDay(day);
    final end = DateUtilsDriveFlow.endOfDay(day);
    final amounts = <RidePlatform, double>{};

    for (final earning in earnings) {
      if (!integratable.contains(earning.platform)) continue;
      if (earning.date.isBefore(start) || earning.date.isAfter(end)) continue;
      amounts[earning.platform] =
          (amounts[earning.platform] ?? 0) + earning.amount;
    }
    return amounts;
  }

  static Map<RidePlatform, double> _tripsByPlatform(
    List<PlatformTripEntity> trips,
    DateTime day,
  ) {
    final start = DateUtilsDriveFlow.startOfDay(day);
    final end = DateUtilsDriveFlow.endOfDay(day);
    final amounts = <RidePlatform, double>{};

    for (final trip in trips) {
      if (!trip.isCompleted || !integratable.contains(trip.platform)) continue;
      if (trip.startedAt.isBefore(start) || trip.startedAt.isAfter(end)) {
        continue;
      }
      amounts[trip.platform] =
          (amounts[trip.platform] ?? 0) + trip.driverPayout;
    }
    return amounts;
  }

  static List<PlatformRevenueTrendPoint> _withDeltas(
    List<PlatformRevenueTrendPoint> points,
  ) {
    if (points.length < 2) return points;

    return [
      for (var i = 0; i < points.length; i++)
        PlatformRevenueTrendPoint(
          date: points[i].date,
          amountsByPlatform: points[i].amountsByPlatform,
          total: points[i].total,
          deltaPercent: i == 0
              ? null
              : _deltaPercent(points[i - 1].total, points[i].total),
        ),
    ];
  }

  static double? _deltaPercent(double previous, double current) {
    if (previous <= 0) return null;
    return ((current - previous) / previous) * 100;
  }

  /// Variação da 1ª metade vs 2ª metade do período (mais estável que dia-a-dia).
  static Map<RidePlatform, double> periodDeltaByPlatform({
    required List<PlatformRevenueTrendPoint> points,
  }) {
    if (points.length < 4) return {};

    final mid = points.length ~/ 2;
    final firstHalf = points.sublist(0, mid);
    final secondHalf = points.sublist(mid);
    final deltas = <RidePlatform, double>{};

    for (final platform in integratable) {
      final prev = firstHalf.fold<double>(
        0,
        (s, p) => s + (p.amountsByPlatform[platform] ?? 0),
      );
      final curr = secondHalf.fold<double>(
        0,
        (s, p) => s + (p.amountsByPlatform[platform] ?? 0),
      );
      final delta = _deltaPercent(prev, curr);
      if (delta != null) deltas[platform] = delta;
    }
    return deltas;
  }
}
