import '../../../../core/constants/ride_platforms.dart';

/// Receita bruta vs lucro líquido por plataforma.
class PlatformNetProfitSlice {
  const PlatformNetProfitSlice({
    required this.platform,
    required this.grossAmount,
    required this.platformFees,
    required this.fuelCost,
    required this.netAmount,
    required this.tripCount,
  });

  final RidePlatform platform;
  final double grossAmount;
  final double platformFees;
  final double fuelCost;
  final double netAmount;
  final int tripCount;

  double get netSharePercent =>
      grossAmount > 0 ? (netAmount / grossAmount) * 100 : 0;
}
