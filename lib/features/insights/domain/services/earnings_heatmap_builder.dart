import '../../../earnings/domain/entities/earning_entity.dart';
import '../entities/earning_time_slot.dart';

/// Agrega ganhos por dia da semana e hora (últimos 60 dias).
abstract final class EarningsHeatmapBuilder {
  static const lookbackDays = 60;
  static const defaultStartHour = 8;

  static List<EarningTimeSlot> build({
    required List<EarningEntity> earnings,
    DateTime? now,
  }) {
    final anchor = now ?? DateTime.now();
    final cutoff = anchor.subtract(const Duration(days: lookbackDays));

    final buckets = <String, _Bucket>{};

    for (final earning in earnings) {
      if (earning.date.isBefore(cutoff)) continue;

      final profit = earning.amount;
      final hours = earning.workedHours;
      if (hours <= 0) continue;

      if (_hasRegisteredHour(earning.date)) {
        _addToBucket(
          buckets,
          weekday: earning.date.weekday,
          hour: earning.date.hour,
          profit: profit,
          hours: hours,
        );
      } else {
        _distributeDateOnly(
          buckets: buckets,
          weekday: earning.date.weekday,
          profit: profit,
          hours: hours,
        );
      }
    }

    final slots = buckets.values
        .map(
          (bucket) => EarningTimeSlot(
            weekday: bucket.weekday,
            hour: bucket.hour,
            totalProfit: bucket.profit,
            totalHours: bucket.hours,
            earningCount: bucket.count,
          ),
        )
        .toList(growable: false);

    slots.sort((a, b) => b.profitPerHour.compareTo(a.profitPerHour));
    return slots;
  }

  static List<EarningTimeSlot> topSlots({
    required List<EarningEntity> earnings,
    int limit = 3,
    DateTime? now,
  }) {
    return build(earnings: earnings, now: now).take(limit).toList(growable: false);
  }

  static bool _hasRegisteredHour(DateTime date) =>
      date.hour != 0 || date.minute != 0;

  static void _distributeDateOnly({
    required Map<String, _Bucket> buckets,
    required int weekday,
    required double profit,
    required double hours,
  }) {
    final span = 14;
    final profitShare = profit / span;
    final hoursShare = hours / span;

    for (var h = defaultStartHour; h < defaultStartHour + span; h++) {
      _addToBucket(
        buckets,
        weekday: weekday,
        hour: h,
        profit: profitShare,
        hours: hoursShare,
      );
    }
  }

  static void _addToBucket(
    Map<String, _Bucket> buckets, {
    required int weekday,
    required int hour,
    required double profit,
    required double hours,
  }) {
    final key = '$weekday-$hour';
    final existing = buckets[key];
    if (existing == null) {
      buckets[key] = _Bucket(
        weekday: weekday,
        hour: hour,
        profit: profit,
        hours: hours,
        count: 1,
      );
    } else {
      buckets[key] = existing.copyWith(
        profit: existing.profit + profit,
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
    required this.profit,
    required this.hours,
    required this.count,
  });

  final int weekday;
  final int hour;
  final double profit;
  final double hours;
  final int count;

  _Bucket copyWith({
    double? profit,
    double? hours,
    int? count,
  }) {
    return _Bucket(
      weekday: weekday,
      hour: hour,
      profit: profit ?? this.profit,
      hours: hours ?? this.hours,
      count: count ?? this.count,
    );
  }
}
