import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/iterable_extensions.dart';
import '../entities/platform_payout_entry.dart';
import '../entities/platform_trip_entity.dart';
import 'platform_payout_rules.dart';

/// Estima datas de crédito a partir das corridas sincronizadas.
abstract final class PlatformPayoutCalendarBuilder {
  static List<PlatformPayoutEntry> build({
    required List<PlatformTripEntity> trips,
    Map<RidePlatform, int>? policyOverrides,
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
      final policy = PlatformPayoutRules.resolve(
        trip.platform,
        partnerOverrides: policyOverrides,
      );
      final expected = DateUtilsDriveFlow.startOfDay(
        tripDate.add(Duration(days: policy.settlementDays)),
      );
      final key = '${trip.platform.value}-${expected.millisecondsSinceEpoch}';

      final existing = grouped[key];
      if (existing == null) {
        grouped[key] = _Group(
          platform: trip.platform,
          expectedDate: expected,
          amount: trip.driverPayout,
          tripCount: 1,
          settlementDays: policy.settlementDays,
          cycleLabel: policy.cycleLabel,
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
            cycleLabel: g.cycleLabel,
          ),
        )
        .toList(growable: false)
      ..sort((a, b) => a.expectedDate.compareTo(b.expectedDate));
  }

  static double pendingTotal(List<PlatformPayoutEntry> entries, {DateTime? now}) {
    final anchor = now ?? DateTime.now();
    final today = DateUtilsDriveFlow.startOfDay(anchor);
    return entries
        .where((e) => !e.expectedDate.isBefore(today))
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
    required this.cycleLabel,
  });

  final RidePlatform platform;
  final DateTime expectedDate;
  final double amount;
  final int tripCount;
  final int settlementDays;
  final String cycleLabel;

  _Group copyWith({double? amount, int? tripCount}) {
    return _Group(
      platform: platform,
      expectedDate: expectedDate,
      amount: amount ?? this.amount,
      tripCount: tripCount ?? this.tripCount,
      settlementDays: settlementDays,
      cycleLabel: cycleLabel,
    );
  }
}
