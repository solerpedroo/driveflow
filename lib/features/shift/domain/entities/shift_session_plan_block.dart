import '../../../../core/constants/ride_platforms.dart';
import '../../../integrations/domain/entities/platform_shift_plan.dart';

/// Bloco horário persistido na sessão de turno ativa.
class ShiftSessionPlanBlock {
  const ShiftSessionPlanBlock({
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

  bool containsHour(int hour) {
    if (endHour <= startHour) {
      return hour >= startHour || hour < endHour;
    }
    return hour >= startHour && hour < endHour;
  }

  factory ShiftSessionPlanBlock.fromPlatform(PlatformShiftPlanBlock block) {
    return ShiftSessionPlanBlock(
      startHour: block.startHour,
      endHour: block.endHour,
      platform: block.platform,
      reason: block.reason,
      expectedRevenuePerHour: block.expectedRevenuePerHour,
    );
  }

  Map<String, dynamic> toJson() => {
        'startHour': startHour,
        'endHour': endHour,
        'platform': platform.value,
        'reason': reason,
        'expectedRevenuePerHour': expectedRevenuePerHour,
      };

  factory ShiftSessionPlanBlock.fromJson(Map<String, dynamic> json) {
    return ShiftSessionPlanBlock(
      startHour: (json['startHour'] as num?)?.toInt() ?? 0,
      endHour: (json['endHour'] as num?)?.toInt() ?? 0,
      platform: RidePlatform.fromValue(json['platform'] as String? ?? ''),
      reason: json['reason'] as String? ?? '',
      expectedRevenuePerHour:
          (json['expectedRevenuePerHour'] as num?)?.toDouble() ?? 0,
    );
  }
}
