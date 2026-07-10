import '../../../../core/constants/ride_platforms.dart';
import '../entities/platform_trip_entity.dart';
import 'platform_catalog.dart';

/// Transparência de taxas — quanto cada app retém do motorista.
class PlatformFeeSnapshot {
  const PlatformFeeSnapshot({
    required this.platform,
    required this.tripCount,
    required this.grossTotal,
    required this.feeTotal,
    required this.payoutTotal,
    required this.avgTakeRatePercent,
    required this.avgPayoutPerTrip,
  });

  final RidePlatform platform;
  final int tripCount;
  final double grossTotal;
  final double feeTotal;
  final double payoutTotal;
  final double avgTakeRatePercent;
  final double avgPayoutPerTrip;

  bool get hasData => tripCount > 0;
}

abstract final class PlatformFeeAnalyzer {
  static List<PlatformFeeSnapshot> analyze(List<PlatformTripEntity> trips) {
    return [
      for (final platform in PlatformCatalog.integratablePlatforms)
        _snapshotFor(platform, trips),
    ].where((s) => s.hasData).toList()
      ..sort((a, b) => a.avgTakeRatePercent.compareTo(b.avgTakeRatePercent));
  }

  static PlatformFeeSnapshot? lowestTakeRate(List<PlatformTripEntity> trips) {
    final snapshots = analyze(trips);
    if (snapshots.isEmpty) return null;
    return snapshots.first;
  }

  static PlatformFeeSnapshot _snapshotFor(
    RidePlatform platform,
    List<PlatformTripEntity> trips,
  ) {
    final items = trips
        .where((t) => t.platform == platform && t.isCompleted)
        .toList(growable: false);

    final gross = items.fold<double>(0, (sum, t) => sum + t.grossAmount);
    final fees = items.fold<double>(0, (sum, t) => sum + t.platformFee);
    final payout = items.fold<double>(0, (sum, t) => sum + t.driverPayout);

    return PlatformFeeSnapshot(
      platform: platform,
      tripCount: items.length,
      grossTotal: gross,
      feeTotal: fees,
      payoutTotal: payout,
      avgTakeRatePercent: gross > 0 ? (fees / gross) * 100 : 0,
      avgPayoutPerTrip: items.isNotEmpty ? payout / items.length : 0,
    );
  }
}
