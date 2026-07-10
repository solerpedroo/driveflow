import '../../../../core/utils/date_utils.dart';
import '../entities/platform_payout_entry.dart';
import '../entities/platform_trip_entity.dart';
import 'platform_payout_rules.dart';

/// Estima datas de crédito a partir das corridas sincronizadas.
abstract final class PlatformPayoutCalendarBuilder {
  static List<PlatformPayoutEntry> build({
    required List<PlatformTripEntity> trips,
    DateTime? now,
  }) {
    final anchor = now ?? DateTime.now();
    final pending = trips.where(
      (t) => t.isCompleted && (t.endedAt ?? t.startedAt).isAfter(
            anchor.subtract(const Duration(days: 30)),
          ),
    );

    final grouped = <String, _Group>{};

    for (final trip in pending) {
      final tripDate = trip.endedAt ?? trip.startedAt;
      final days = PlatformPayoutRules.settlementDays(trip.platform);
      final expected = DateUtilsDriveFlow.startOfDay(
        tripDate.add(Duration(days: days)),
      );
      final key = '${trip.platform.value}-${expected.millisecondsSinceEpoch}';

      final existing = grouped[key];
      if (existing == null) {
        grouped[key] = _Group(
          platform: trip.platform,
          expectedDate: expected,
          amount: trip.driverPayout,
          tripCount: 1,
          settlementDays: days,
        );
      } else {
        grouped[key] = existing.copyWith(
          amount: existing.amount + trip.driverPayout,
          tripCount: existing.tripCount + 1,
        );
      }
    }

    return grouped.values
        .map(
          (g) => PlatformPayoutEntry(
            platform: g.platform,
            expectedDate: g.expectedDate,
            amount: g.amount,
            tripCount: g.tripCount,
            settlementDays: g.settlementDays,
          ),
        )
        .toList(growable: false)
      ..sort((a, b) => a.expectedDate.compareTo(b.expectedDate));
  }

  static double pendingTotal(List<PlatformPayoutEntry> entries) {
    final now = DateTime.now();
    return entries
        .where((e) => !e.expectedDate.isBefore(now))
        .fold<double>(0, (s, e) => s + e.amount);
  }
}

class _Group {
  const _Group({
    required this.platform,
    required this.expectedDate,
    required this.amount,
    required this.tripCount,
    required this.settlementDays,
  });

  final RidePlatform platform;
  final DateTime expectedDate;
  final double amount;
  final int tripCount;
  final int settlementDays;

  _Group copyWith({double? amount, int? tripCount}) {
    return _Group(
      platform: platform,
      expectedDate: expectedDate,
      amount: amount ?? this.amount,
      tripCount: tripCount ?? this.tripCount,
      settlementDays: settlementDays,
    );
  }
}
