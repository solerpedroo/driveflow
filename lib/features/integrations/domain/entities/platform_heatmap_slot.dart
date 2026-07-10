import '../../../../core/constants/ride_platforms.dart';

/// Slot do heatmap 7×24 por plataforma.
class PlatformHeatmapSlot {
  const PlatformHeatmapSlot({
    required this.weekday,
    required this.hour,
    required this.platform,
    required this.revenuePerHour,
    required this.tripCount,
    required this.totalRevenue,
  });

  final int weekday;
  final int hour;
  final RidePlatform platform;
  final double revenuePerHour;
  final int tripCount;
  final double totalRevenue;

  String get weekdayLabel {
    const labels = ['', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return labels[weekday.clamp(1, 7)];
  }

  String get hourLabel => '${hour.toString().padLeft(2, '0')}h';
}
