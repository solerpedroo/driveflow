import '../../../../core/constants/ride_platforms.dart';
import 'shift_session_plan_block.dart';

/// Registro persistido de um turno encerrado com métricas consolidadas.
class ShiftHistoryEntry {
  const ShiftHistoryEntry({
    required this.id,
    required this.userId,
    required this.startedAt,
    required this.endedAt,
    required this.elapsed,
    required this.accumulatedPause,
    required this.isTaxiMode,
    required this.revenue,
    required this.rides,
    required this.adherenceScore,
    required this.matchedPlanBlocks,
    required this.totalPlanBlocks,
    required this.planBlocks,
    required this.revenueByPlatform,
    this.vehicleId,
    this.revenuePerHour,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final DateTime startedAt;
  final DateTime endedAt;
  final Duration elapsed;
  final Duration accumulatedPause;
  final String? vehicleId;
  final bool isTaxiMode;
  final double revenue;
  final int rides;
  final double? revenuePerHour;
  final double adherenceScore;
  final int matchedPlanBlocks;
  final int totalPlanBlocks;
  final List<ShiftSessionPlanBlock> planBlocks;
  final Map<RidePlatform, double> revenueByPlatform;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
        'elapsedMs': elapsed.inMilliseconds,
        'accumulatedPauseMs': accumulatedPause.inMilliseconds,
        'vehicleId': vehicleId,
        'isTaxiMode': isTaxiMode,
        'revenue': revenue,
        'rides': rides,
        'revenuePerHour': revenuePerHour,
        'adherenceScore': adherenceScore,
        'matchedPlanBlocks': matchedPlanBlocks,
        'totalPlanBlocks': totalPlanBlocks,
        'planBlocks': planBlocks.map((block) => block.toJson()).toList(),
        'revenueByPlatform': revenueByPlatform.map(
          (platform, amount) => MapEntry(platform.value, amount),
        ),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory ShiftHistoryEntry.fromJson(Map<String, dynamic> json) {
    final platformRevenue = <RidePlatform, double>{};
    final rawPlatforms = json['revenueByPlatform'];
    if (rawPlatforms is Map) {
      rawPlatforms.forEach((key, value) {
        platformRevenue[RidePlatform.fromValue(key as String? ?? '')] =
            (value as num?)?.toDouble() ?? 0;
      });
    }

    return ShiftHistoryEntry(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ??
          DateTime.now(),
      endedAt: DateTime.tryParse(json['endedAt'] as String? ?? '') ??
          DateTime.now(),
      elapsed: Duration(
        milliseconds: (json['elapsedMs'] as num?)?.toInt() ?? 0,
      ),
      accumulatedPause: Duration(
        milliseconds: (json['accumulatedPauseMs'] as num?)?.toInt() ?? 0,
      ),
      vehicleId: json['vehicleId'] as String?,
      isTaxiMode: json['isTaxiMode'] as bool? ?? false,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      rides: (json['rides'] as num?)?.toInt() ?? 0,
      revenuePerHour: (json['revenuePerHour'] as num?)?.toDouble(),
      adherenceScore: (json['adherenceScore'] as num?)?.toDouble() ?? 0,
      matchedPlanBlocks: (json['matchedPlanBlocks'] as num?)?.toInt() ?? 0,
      totalPlanBlocks: (json['totalPlanBlocks'] as num?)?.toInt() ?? 0,
      planBlocks: (json['planBlocks'] as List?)
              ?.whereType<Map>()
              .map(
                (item) => ShiftSessionPlanBlock.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(growable: false) ??
          const [],
      revenueByPlatform: platformRevenue,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }
}
