import '../../../../core/constants/ride_platforms.dart';
import '../../../earnings/domain/entities/earning_entity.dart';

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
}
