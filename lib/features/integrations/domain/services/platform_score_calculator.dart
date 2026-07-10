import '../../../../core/constants/ride_platforms.dart';
import '../../../earnings/domain/entities/earning_entity.dart';
import '../entities/platform_score_snapshot.dart';
import '../entities/platform_trip_entity.dart';
import 'platform_fee_analyzer.dart';
import 'platform_performance_analyzer.dart';

/// Score composto: R$/h (40%) + baixa taxa (30%) + volume (20%) + consistência (10%).
abstract final class PlatformScoreCalculator {
  static List<PlatformScoreSnapshot> calculate(List<PlatformTripEntity> trips) {
    final earnings = _earningsFromTrips(trips);
    final performance =
        PlatformPerformanceAnalyzer.analyze(earnings).where((s) => s.hasData).toList();
    if (performance.isEmpty) return const [];

    final fees = PlatformFeeAnalyzer.analyze(trips);
    final feeByPlatform = {for (final f in fees) f.platform: f};
    final maxHourly =
        performance.map((p) => p.avgPerHour).reduce((a, b) => a > b ? a : b);
    final maxTrips =
        performance.map((p) => p.totalRides).reduce((a, b) => a > b ? a : b);

    final scores = <PlatformScoreSnapshot>[];
    for (final perf in performance) {
      final fee = feeByPlatform[perf.platform];
      final composite = _compositeScore(
        avgPerHour: perf.avgPerHour,
        takeRatePercent: fee?.avgTakeRatePercent ?? 25,
        tripCount: perf.totalRides,
        sharePercent: perf.sharePercent,
        maxHourly: maxHourly,
        maxTrips: maxTrips,
      );

      scores.add(
        PlatformScoreSnapshot(
          platform: perf.platform,
          score: composite,
          avgPerHour: perf.avgPerHour,
          takeRatePercent: fee?.avgTakeRatePercent ?? 0,
          tripCount: perf.totalRides,
          consistencyPercent: perf.sharePercent,
          label: _labelFor(composite),
        ),
      );
    }

    scores.sort((a, b) => b.score.compareTo(a.score));
    return scores;
  }

  static double _compositeScore({
    required double avgPerHour,
    required double takeRatePercent,
    required int tripCount,
    required double sharePercent,
    required double maxHourly,
    required int maxTrips,
  }) {
    final hourlyScore = maxHourly > 0 ? avgPerHour / maxHourly : 0;
    final feeScore = (1 - (takeRatePercent / 40)).clamp(0.0, 1.0);
    final volumeScore = maxTrips > 0 ? tripCount / maxTrips : 0.0;
    final consistency = sharePercent / 100;

    return ((hourlyScore * 0.4) +
            (feeScore * 0.3) +
            (volumeScore * 0.2) +
            (consistency * 0.1)) *
        100;
  }

  static String _labelFor(double score) {
    if (score >= 80) return 'Excelente';
    if (score >= 60) return 'Bom';
    if (score >= 40) return 'Regular';
    return 'Fraco';
  }

  static List<EarningEntity> _earningsFromTrips(List<PlatformTripEntity> trips) {
    final buckets = <String, List<PlatformTripEntity>>{};
    for (final trip in trips.where((t) => t.isCompleted)) {
      final day = trip.startedAt.toIso8601String().substring(0, 10);
      buckets.putIfAbsent('${trip.platform.value}:$day', () => []).add(trip);
    }

    final earnings = <EarningEntity>[];
    var seq = 0;
    for (final group in buckets.values) {
      final first = group.first;
      earnings.add(
        EarningEntity(
          id: 'score-${seq++}',
          userId: first.userId,
          platform: first.platform,
          amount: group.fold<double>(0, (s, t) => s + t.driverPayout),
          rides: group.length,
          workedHours: group.fold<double>(
            0,
            (s, t) => s + (t.durationMinutes != null ? t.durationMinutes! / 60 : 0),
          ),
          date: first.startedAt,
        ),
      );
    }
    return earnings;
  }
}
