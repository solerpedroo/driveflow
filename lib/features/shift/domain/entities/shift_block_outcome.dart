import '../../../../core/constants/ride_platforms.dart';
import 'shift_session_plan_block.dart';

/// Resultado de um bloco do plano vs ganhos reais no turno.
class ShiftBlockOutcome {
  const ShiftBlockOutcome({
    required this.block,
    required this.actualPlatform,
    required this.matched,
    required this.revenue,
  });

  final ShiftSessionPlanBlock block;
  final RidePlatform? actualPlatform;
  final bool matched;
  final double revenue;

  Map<String, dynamic> toJson() => {
        'block': block.toJson(),
        'actualPlatform': actualPlatform?.value,
        'matched': matched,
        'revenue': revenue,
      };

  factory ShiftBlockOutcome.fromJson(Map<String, dynamic> json) {
    return ShiftBlockOutcome(
      block: ShiftSessionPlanBlock.fromJson(
        Map<String, dynamic>.from(json['block'] as Map? ?? {}),
      ),
      actualPlatform: json['actualPlatform'] == null
          ? null
          : RidePlatform.fromValue(json['actualPlatform'] as String? ?? ''),
      matched: json['matched'] as bool? ?? false,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
    );
  }
}
