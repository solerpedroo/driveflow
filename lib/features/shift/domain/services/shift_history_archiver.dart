import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/ride_platforms.dart';
import '../entities/shift_history_entry.dart';
import '../entities/shift_block_outcome.dart';
import '../entities/shift_retrospective.dart';
import '../entities/shift_session_entity.dart';

/// Monta entrada de histórico ao encerrar turno.
abstract final class ShiftHistoryArchiver {
  static ShiftHistoryEntry build({
    required ShiftSessionEntity session,
    required String userId,
    required double revenue,
    required int rides,
    required double? revenuePerHour,
    required double adherenceScore,
    required int matchedPlanBlocks,
    required int totalPlanBlocks,
    required Map<RidePlatform, double> revenueByPlatform,
    List<ShiftBlockOutcome> blockOutcomes = const [],
    double expenses = 0,
    double? netCash,
    Map<ExpenseCategory, double> expensesByCategory = const {},
  }) {
    final endedAt = session.endedAt ?? DateTime.now();
    final elapsed = session.elapsedAt(endedAt);

    return ShiftHistoryEntry(
      id: session.id,
      userId: userId,
      startedAt: session.startedAt,
      endedAt: endedAt,
      elapsed: elapsed,
      accumulatedPause: session.accumulatedPause,
      vehicleId: session.vehicleId,
      isTaxiMode: session.isTaxiMode,
      revenue: revenue,
      rides: rides,
      revenuePerHour: revenuePerHour,
      expenses: expenses,
      netCash: netCash ?? revenue - expenses,
      expensesByCategory: expensesByCategory,
      adherenceScore: adherenceScore,
      matchedPlanBlocks: matchedPlanBlocks,
      totalPlanBlocks: totalPlanBlocks,
      planBlocks: session.planBlocks,
      revenueByPlatform: revenueByPlatform,
      blockOutcomes: blockOutcomes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
