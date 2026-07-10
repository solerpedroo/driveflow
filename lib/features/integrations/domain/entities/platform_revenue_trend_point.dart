import '../../../../core/constants/ride_platforms.dart';

/// Ponto diário da série de receita por plataforma.
class PlatformRevenueTrendPoint {
  const PlatformRevenueTrendPoint({
    required this.date,
    required this.amountsByPlatform,
    required this.total,
    this.deltaPercent,
  });

  final DateTime date;
  final Map<RidePlatform, double> amountsByPlatform;
  final double total;

  /// Variação % vs mesmo dia no período anterior (quando disponível).
  final double? deltaPercent;

  String get weekdayLabel {
    const labels = ['', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return labels[date.weekday];
  }
}
