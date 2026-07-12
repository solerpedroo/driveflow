import '../../../../core/constants/ride_platforms.dart';
import '../../../earnings/domain/entities/earning_entity.dart';
import '../entities/earning_source.dart';
import '../entities/platform_trip_entity.dart';

/// Agrega corridas sincronizadas em ganhos diários por plataforma.
abstract final class EarningsRollupService {
  static List<EarningDraft> rollupDaily({
    required List<PlatformTripEntity> trips,
    String? vehicleId,
  }) {
    final completed =
        trips.where((t) => t.isCompleted).toList(growable: false);
    if (completed.isEmpty) return const [];

    final buckets = <String, List<PlatformTripEntity>>{};
    for (final trip in completed) {
      final key = _bucketKey(trip.platform, trip.startedAt);
      buckets.putIfAbsent(key, () => []).add(trip);
    }

    return [
      for (final entry in buckets.entries) _draftFromBucket(
        entry.value,
        vehicleId: vehicleId,
      ),
    ]..sort((a, b) => b.date.compareTo(a.date));
  }

  static EarningDraft _draftFromBucket(
    List<PlatformTripEntity> trips, {
    String? vehicleId,
  }) {
    final platform = trips.first.platform;
    final date = _dayStart(trips.first.startedAt);
    final amount = trips.fold<double>(0, (sum, t) => sum + t.driverPayout);
    final hours = trips.fold<double>(0, (sum, t) => sum + t.workedHours);

    return EarningDraft(
      platform: platform,
      amount: amount,
      rides: trips.length,
      workedHours: double.parse(hours.toStringAsFixed(2)),
      date: date,
      vehicleId: vehicleId,
      note: 'Atualização automática · ${trips.length} corridas',
      source: EarningSource.apiSync,
      externalId: 'rollup:${platform.value}:${date.toIso8601String().substring(0, 10)}',
    );
  }

  static String _bucketKey(RidePlatform platform, DateTime startedAt) {
    final day = _dayStart(startedAt);
    return '${platform.value}:${day.toIso8601String().substring(0, 10)}';
  }

  static DateTime _dayStart(DateTime value) {
    final local = value.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}
