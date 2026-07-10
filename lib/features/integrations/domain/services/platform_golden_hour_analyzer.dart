import '../../../../core/constants/ride_platforms.dart';
import '../../../earnings/domain/entities/earning_entity.dart';
import '../entities/platform_golden_hour_slot.dart';
import '../entities/platform_trip_entity.dart';
import 'platform_catalog.dart';

/// Cruza histórico de corridas com slots de horário para achar o horário de ouro.
abstract final class PlatformGoldenHourAnalyzer {
  static const _weekdays = [
    'Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb',
  ];

  static List<PlatformGoldenHourSlot> analyze(List<PlatformTripEntity> trips) {
    if (trips.isEmpty) return const [];

    final slots = <String, List<PlatformTripEntity>>{};
    for (final trip in trips) {
      if (!trip.isCompleted) continue;
      final local = trip.startedAt.toLocal();
      final key = '${trip.platform.value}:${local.weekday}:${local.hour}';
      slots.putIfAbsent(key, () => []).add(trip);
    }

    final results = <PlatformGoldenHourSlot>[];
    for (final entry in slots.entries) {
      final parts = entry.key.split(':');
      final platform = RidePlatform.fromValue(parts[0]);
      final weekday = int.parse(parts[1]);
      final hour = int.parse(parts[2]);
      final items = entry.value;

      final totalPayout =
          items.fold<double>(0, (sum, t) => sum + t.driverPayout);
      final totalHours = items.fold<double>(
        0,
        (sum, t) => sum + t.workedHours,
      );
      final avgPerHour = totalHours > 0 ? totalPayout / totalHours : 0;

      results.add(
        PlatformGoldenHourSlot(
          platform: platform,
          weekdayLabel: _weekdays[weekday % 7],
          hourLabel: '${hour.toString().padLeft(2, '0')}h',
          avgPayoutPerHour: avgPerHour,
          tripCount: items.length,
          confidence: (items.length / 5).clamp(0.4, 0.95),
        ),
      );
    }

    results.sort((a, b) => b.avgPayoutPerHour.compareTo(a.avgPayoutPerHour));
    return results.take(6).toList();
  }

  static PlatformGoldenHourSlot? bestNow({
    required List<PlatformTripEntity> trips,
    DateTime? at,
  }) {
    final now = at ?? DateTime.now();
    final local = now.toLocal();
    final matches = analyze(trips).where(
      (slot) =>
          slot.weekdayLabel == _weekdays[local.weekday % 7] &&
          slot.hourLabel == '${local.hour.toString().padLeft(2, '0')}h',
    );
    if (matches.isEmpty) {
      final all = analyze(trips);
      return all.isEmpty ? null : all.first;
    }
    return matches.first;
  }

  /// Fallback com earnings quando trips ainda não sincronizaram.
  static PlatformGoldenHourSlot? fromEarnings(List<EarningEntity> earnings) {
    if (earnings.isEmpty) return null;

    final integratable = earnings
        .where((e) => PlatformCatalog.integratablePlatforms.contains(e.platform))
        .toList();
    if (integratable.isEmpty) return null;

    integratable.sort((a, b) {
      final aRate = a.workedHours > 0 ? a.amount / a.workedHours : 0;
      final bRate = b.workedHours > 0 ? b.amount / b.workedHours : 0;
      return bRate.compareTo(aRate);
    });

    final best = integratable.first;
    final rate = best.workedHours > 0 ? best.amount / best.workedHours : 0;
    final hour = best.date.toLocal().hour;

    return PlatformGoldenHourSlot(
      platform: best.platform,
      weekdayLabel: _weekdays[best.date.weekday % 7],
      hourLabel: '${hour.toString().padLeft(2, '0')}h',
      avgPayoutPerHour: rate,
      tripCount: best.rides,
      confidence: 0.5,
    );
  }
}
