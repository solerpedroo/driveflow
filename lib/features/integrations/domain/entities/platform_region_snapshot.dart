import '../../../../core/constants/ride_platforms.dart';

/// Região/zona com melhor desempenho por app.
class PlatformRegionSnapshot {
  const PlatformRegionSnapshot({
    required this.platform,
    required this.regionLabel,
    required this.avgPayout,
    required this.tripCount,
    required this.totalPayout,
    this.isEstimated = false,
  });

  final RidePlatform platform;
  final String regionLabel;
  final double avgPayout;
  final int tripCount;
  final double totalPayout;

  /// `true` quando o rótulo veio de distância/área genérica, não de endereço.
  final bool isEstimated;
}
