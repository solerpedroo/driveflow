import '../../../../core/constants/ride_platforms.dart';
import '../../domain/entities/shift_block_outcome.dart';
import '../../domain/entities/shift_history_entry.dart';
import '../../domain/entities/shift_session_plan_block.dart';
import '../schema/shift_sessions_schema.dart';

abstract final class ShiftSessionsMapper {
  static ShiftHistoryEntry fromRow(Map<String, dynamic> row) {
    final planBlocksRaw = row[ShiftSessionsSchema.planBlocks];
    final planBlocks = planBlocksRaw is List
        ? planBlocksRaw
            .whereType<Map>()
            .map(
              (item) => ShiftSessionPlanBlock.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false)
        : const <ShiftSessionPlanBlock>[];

    final revenueByPlatform = <RidePlatform, double>{};
    final platformRaw = row[ShiftSessionsSchema.revenueByPlatform];
    if (platformRaw is Map) {
      platformRaw.forEach((key, value) {
        revenueByPlatform[RidePlatform.fromValue(key as String? ?? '')] =
            (value as num?)?.toDouble() ?? 0;
      });
    }

    final blockOutcomesRaw = row[ShiftSessionsSchema.blockOutcomes];
    final blockOutcomes = blockOutcomesRaw is List
        ? blockOutcomesRaw
            .whereType<Map>()
            .map(
              (item) => ShiftBlockOutcome.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false)
        : const <ShiftBlockOutcome>[];

    return ShiftHistoryEntry(
      id: row[ShiftSessionsSchema.id] as String,
      userId: row[ShiftSessionsSchema.userId] as String,
      startedAt: _toDateTime(row[ShiftSessionsSchema.startedAt]) ?? DateTime.now(),
      endedAt: _toDateTime(row[ShiftSessionsSchema.endedAt]) ?? DateTime.now(),
      elapsed: Duration(
        milliseconds: (row[ShiftSessionsSchema.elapsedMs] as num?)?.toInt() ?? 0,
      ),
      accumulatedPause: Duration(
        milliseconds:
            (row[ShiftSessionsSchema.accumulatedPauseMs] as num?)?.toInt() ?? 0,
      ),
      vehicleId: row[ShiftSessionsSchema.vehicleId] as String?,
      isTaxiMode: row[ShiftSessionsSchema.isTaxiMode] as bool? ?? false,
      revenue: _toDouble(row[ShiftSessionsSchema.revenue]) ?? 0,
      rides: (row[ShiftSessionsSchema.rides] as num?)?.toInt() ?? 0,
      revenuePerHour: _toDouble(row[ShiftSessionsSchema.revenuePerHour]),
      adherenceScore: _toDouble(row[ShiftSessionsSchema.adherenceScore]) ?? 0,
      matchedPlanBlocks:
          (row[ShiftSessionsSchema.matchedPlanBlocks] as num?)?.toInt() ?? 0,
      totalPlanBlocks:
          (row[ShiftSessionsSchema.totalPlanBlocks] as num?)?.toInt() ?? 0,
      planBlocks: planBlocks,
      revenueByPlatform: revenueByPlatform,
      blockOutcomes: blockOutcomes,
      createdAt: _toDateTime(row[ShiftSessionsSchema.createdAt]),
      updatedAt: _toDateTime(row[ShiftSessionsSchema.updatedAt]),
    );
  }

  static Map<String, dynamic> toInsert(ShiftHistoryEntry entry) {
    return {
      ShiftSessionsSchema.userId: entry.userId,
      ShiftSessionsSchema.vehicleId: entry.vehicleId,
      ShiftSessionsSchema.startedAt: entry.startedAt.toUtc().toIso8601String(),
      ShiftSessionsSchema.endedAt: entry.endedAt.toUtc().toIso8601String(),
      ShiftSessionsSchema.elapsedMs: entry.elapsed.inMilliseconds,
      ShiftSessionsSchema.accumulatedPauseMs: entry.accumulatedPause.inMilliseconds,
      ShiftSessionsSchema.isTaxiMode: entry.isTaxiMode,
      ShiftSessionsSchema.status: 'completed',
      ShiftSessionsSchema.planBlocks:
          entry.planBlocks.map((block) => block.toJson()).toList(),
      ShiftSessionsSchema.revenue: entry.revenue,
      ShiftSessionsSchema.rides: entry.rides,
      ShiftSessionsSchema.revenuePerHour: entry.revenuePerHour,
      ShiftSessionsSchema.adherenceScore: entry.adherenceScore,
      ShiftSessionsSchema.matchedPlanBlocks: entry.matchedPlanBlocks,
      ShiftSessionsSchema.totalPlanBlocks: entry.totalPlanBlocks,
      ShiftSessionsSchema.revenueByPlatform: entry.revenueByPlatform.map(
        (platform, amount) => MapEntry(platform.value, amount),
      ),
      ShiftSessionsSchema.blockOutcomes:
          entry.blockOutcomes.map((outcome) => outcome.toJson()).toList(),
    };
  }

  static Map<String, dynamic> toRow(ShiftHistoryEntry entry) {
    return {
      ShiftSessionsSchema.id: entry.id,
      ...toInsert(entry),
      if (entry.createdAt != null)
        ShiftSessionsSchema.createdAt: entry.createdAt!.toUtc().toIso8601String(),
      if (entry.updatedAt != null)
        ShiftSessionsSchema.updatedAt: entry.updatedAt!.toUtc().toIso8601String(),
    };
  }

  static double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _toDateTime(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
