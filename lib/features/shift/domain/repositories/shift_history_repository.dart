import '../../../../core/constants/ride_platforms.dart';
import '../entities/shift_block_outcome.dart';
import '../entities/shift_history_entry.dart';
import '../entities/shift_session_entity.dart';

/// Persistência e sincronização do histórico de turnos.
abstract class ShiftHistoryRepository {
  Stream<List<ShiftHistoryEntry>> watchHistory();

  Future<List<ShiftHistoryEntry>> fetchHistory();

  Future<ShiftHistoryEntry?> readById(String id);

  Future<ShiftHistoryEntry> archiveCompleted({
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
  });
}
