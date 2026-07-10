import '../../../../core/constants/ride_platforms.dart';

/// Melhor janela de horário por plataforma (horário de ouro).
class PlatformGoldenHourSlot {
  const PlatformGoldenHourSlot({
    required this.platform,
    required this.weekdayLabel,
    required this.hourLabel,
    required this.avgPayoutPerHour,
    required this.tripCount,
    required this.confidence,
  });

  final RidePlatform platform;
  final String weekdayLabel;
  final String hourLabel;
  final double avgPayoutPerHour;
  final int tripCount;
  final double confidence;
}
