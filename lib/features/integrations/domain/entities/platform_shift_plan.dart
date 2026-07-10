import '../../../../core/constants/ride_platforms.dart';

/// Bloco horário do plano de turno sugerido.
class PlatformShiftPlanBlock {
  const PlatformShiftPlanBlock({
    required this.startHour,
    required this.endHour,
    required this.platform,
    required this.reason,
    required this.expectedRevenuePerHour,
  });

  final int startHour;
  final int endHour;
  final RidePlatform platform;
  final String reason;
  final double expectedRevenuePerHour;

  String get timeRange =>
      '${startHour.toString().padLeft(2, '0')}h–${endHour.toString().padLeft(2, '0')}h';
}

/// Plano de turno para as próximas horas.
class PlatformShiftPlan {
  const PlatformShiftPlan({
    required this.blocks,
    required this.totalHours,
    required this.projectedRevenue,
  });

  final List<PlatformShiftPlanBlock> blocks;
  final int totalHours;
  final double projectedRevenue;

  bool get isEmpty => blocks.isEmpty;
}
