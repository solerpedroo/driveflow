import '../../../../core/constants/ride_platforms.dart';
import '../../../integrations/domain/entities/platform_shift_recommendation.dart';
import '../entities/shift_plan_adherence.dart';
import '../entities/shift_session_entity.dart';
import '../entities/shift_session_plan_block.dart';

/// Compara sessão ativa com plano e recomendação em tempo real.
abstract final class ShiftPlanTracker {
  static ShiftSessionPlanBlock? currentBlock({
    required ShiftSessionEntity session,
    required DateTime now,
  }) {
    if (session.planBlocks.isEmpty) return null;

    final hour = now.hour;
    for (final block in session.planBlocks) {
      if (block.containsHour(hour)) return block;
    }

    return session.planBlocks.first;
  }

  static ShiftPlanAdherence evaluate({
    required ShiftSessionEntity session,
    required DateTime now,
    PlatformShiftRecommendation? recommendation,
  }) {
    final current = currentBlock(session: session, now: now);
    final recommended = recommendation?.recommended;

    if (current == null || recommended == null) {
      return ShiftPlanAdherence(
        currentBlock: current,
        recommendedPlatform: recommended,
        shouldSwitch: false,
      );
    }

    return ShiftPlanAdherence(
      currentBlock: current,
      recommendedPlatform: recommended,
      shouldSwitch: current.platform != recommended,
    );
  }

  static RidePlatform? suggestedPlatform({
    required ShiftSessionEntity session,
    required DateTime now,
    PlatformShiftRecommendation? recommendation,
  }) {
    final adherence = evaluate(
      session: session,
      now: now,
      recommendation: recommendation,
    );
    if (!adherence.shouldSwitch) return null;
    return adherence.recommendedPlatform;
  }
}
