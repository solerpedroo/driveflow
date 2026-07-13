import '../../../../core/constants/ride_platforms.dart';
import 'shift_session_plan_block.dart';

/// Aderência ao plano de turno no bloco horário atual.
class ShiftPlanAdherence {
  const ShiftPlanAdherence({
    required this.currentBlock,
    required this.recommendedPlatform,
    required this.shouldSwitch,
  });

  final ShiftSessionPlanBlock? currentBlock;
  final RidePlatform? recommendedPlatform;
  final bool shouldSwitch;

  static const none = ShiftPlanAdherence(
    currentBlock: null,
    recommendedPlatform: null,
    shouldSwitch: false,
  );
}
