import '../../../../core/constants/ride_platforms.dart';
import '../../../earnings/domain/entities/earning_entity.dart';
import '../entities/platform_performance_snapshot.dart';
import 'platform_catalog.dart';

/// Compara desempenho financeiro entre Uber, 99 e InDrive.
abstract final class PlatformPerformanceAnalyzer {
  static List<PlatformPerformanceSnapshot> analyze(
    List<EarningEntity> earnings, {
    Iterable<RidePlatform> platforms = PlatformCatalog.integratablePlatforms,
  }) {
    final scoped = earnings
        .where((e) => platforms.contains(e.platform))
        .toList(growable: false);

    final totalAmount = scoped.fold<double>(0, (sum, e) => sum + e.amount);

    return [
      for (final platform in platforms)
        _snapshotFor(platform, scoped, totalAmount),
    ]..sort((a, b) => b.avgPerHour.compareTo(a.avgPerHour));
  }

  static PlatformPerformanceSnapshot? bestPerHour(
    List<EarningEntity> earnings,
  ) {
    final snapshots = analyze(earnings).where((s) => s.hasData).toList();
    if (snapshots.isEmpty) return null;
    return snapshots.first;
  }

  static PlatformPerformanceSnapshot _snapshotFor(
    RidePlatform platform,
    List<EarningEntity> earnings,
    double totalAmount,
  ) {
    final items =
        earnings.where((e) => e.platform == platform).toList(growable: false);

    final amount = items.fold<double>(0, (sum, e) => sum + e.amount);
    final rides = items.fold<int>(0, (sum, e) => sum + e.rides);
    final hours = items.fold<double>(0, (sum, e) => sum + e.workedHours);

    return PlatformPerformanceSnapshot(
      platform: platform,
      totalAmount: amount,
      totalRides: rides,
      totalHours: hours,
      avgPerRide: rides > 0 ? amount / rides : 0,
      avgPerHour: hours > 0 ? amount / hours : 0,
      sharePercent: totalAmount > 0 ? (amount / totalAmount) * 100 : 0,
    );
  }
}
