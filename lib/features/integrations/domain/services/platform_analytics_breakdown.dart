import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../earnings/domain/entities/earning_entity.dart';
import '../entities/platform_trip_entity.dart';

/// Fatia de receita por plataforma para gráficos e relatórios.
class PlatformRevenueSlice {
  const PlatformRevenueSlice({
    required this.platform,
    required this.amount,
    required this.rides,
    required this.sharePercent,
  });

  final RidePlatform platform;
  final double amount;
  final int rides;
  final double sharePercent;
}

/// Breakdown de ganhos por Uber, 99 e InDrive.
abstract final class PlatformAnalyticsBreakdown {
  static const integratable = {
    RidePlatform.uber,
    RidePlatform.ninetyNine,
    RidePlatform.inDrive,
  };

  static List<PlatformRevenueSlice> fromEarnings(List<EarningEntity> earnings) {
    final integratableEarnings = earnings.where(
      (e) => integratable.contains(e.platform),
    );

    final total =
        integratableEarnings.fold<double>(0, (s, e) => s + e.amount);
    final byPlatform = <RidePlatform, ({double amount, int rides})>{};

    for (final earning in integratableEarnings) {
      final current = byPlatform[earning.platform];
      byPlatform[earning.platform] = (
        amount: (current?.amount ?? 0) + earning.amount,
        rides: (current?.rides ?? 0) + earning.rides,
      );
    }

    return [
      for (final entry in byPlatform.entries)
        PlatformRevenueSlice(
          platform: entry.key,
          amount: entry.value.amount,
          rides: entry.value.rides,
          sharePercent: total > 0 ? (entry.value.amount / total) * 100 : 0,
        ),
    ]..sort((a, b) => b.amount.compareTo(a.amount));
  }

  static List<PlatformRevenueSlice> fromTrips(List<PlatformTripEntity> trips) {
    final completed = trips.where(
      (t) => t.isCompleted && integratable.contains(t.platform),
    );
    final total = completed.fold<double>(0, (s, t) => s + t.driverPayout);
    final byPlatform = <RidePlatform, ({double amount, int rides})>{};

    for (final trip in completed) {
      final current = byPlatform[trip.platform];
      byPlatform[trip.platform] = (
        amount: (current?.amount ?? 0) + trip.driverPayout,
        rides: (current?.rides ?? 0) + 1,
      );
    }

    return [
      for (final entry in byPlatform.entries)
        PlatformRevenueSlice(
          platform: entry.key,
          amount: entry.value.amount,
          rides: entry.value.rides,
          sharePercent: total > 0 ? (entry.value.amount / total) * 100 : 0,
        ),
    ]..sort((a, b) => b.amount.compareTo(a.amount));
  }

  /// Mix do dia — prioriza corridas sincronizadas; fallback para ganhos manuais.
  static List<PlatformRevenueSlice> todayMix({
    required List<EarningEntity> earnings,
    required List<PlatformTripEntity> trips,
    DateTime? anchor,
  }) {
    final now = anchor ?? DateTime.now();
    final start = DateUtilsDriveFlow.startOfDay(now);
    final end = DateUtilsDriveFlow.endOfDay(now);

    final todayTrips = trips.where(
      (t) =>
          t.isCompleted &&
          !t.startedAt.isBefore(start) &&
          !t.startedAt.isAfter(end),
    );

    if (todayTrips.isNotEmpty) {
      return fromTrips(todayTrips.toList());
    }

    final todayEarnings = earnings
        .where(
          (e) =>
              integratable.contains(e.platform) &&
              !e.date.isBefore(start) &&
              !e.date.isAfter(end),
        )
        .toList();

    return fromEarnings(todayEarnings);
  }
}
