import 'shift_session_plan_block.dart';
import 'shift_session_status.dart';

/// Sessão de turno ativa ou encerrada recentemente.
class ShiftSessionEntity {
  const ShiftSessionEntity({
    required this.id,
    required this.startedAt,
    required this.status,
    required this.planBlocks,
    required this.isTaxiMode,
    this.endedAt,
    this.pausedAt,
    this.accumulatedPause = Duration.zero,
    this.vehicleId,
  });

  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final DateTime? pausedAt;
  final Duration accumulatedPause;
  final String? vehicleId;
  final ShiftSessionStatus status;
  final List<ShiftSessionPlanBlock> planBlocks;
  final bool isTaxiMode;

  bool get isActive => status.isActiveLike;

  Duration elapsedAt(DateTime now) {
    var total = now.difference(startedAt) - accumulatedPause;
    if (status == ShiftSessionStatus.paused && pausedAt != null) {
      total -= now.difference(pausedAt!);
    }
    return total.isNegative ? Duration.zero : total;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt?.toIso8601String(),
        'pausedAt': pausedAt?.toIso8601String(),
        'accumulatedPauseMs': accumulatedPause.inMilliseconds,
        'vehicleId': vehicleId,
        'status': status.value,
        'planBlocks': planBlocks.map((block) => block.toJson()).toList(),
        'isTaxiMode': isTaxiMode,
      };

  factory ShiftSessionEntity.fromJson(Map<String, dynamic> json) {
    return ShiftSessionEntity(
      id: json['id'] as String? ?? '',
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ??
          DateTime.now(),
      endedAt: DateTime.tryParse(json['endedAt'] as String? ?? ''),
      pausedAt: DateTime.tryParse(json['pausedAt'] as String? ?? ''),
      accumulatedPause: Duration(
        milliseconds: (json['accumulatedPauseMs'] as num?)?.toInt() ?? 0,
      ),
      vehicleId: json['vehicleId'] as String?,
      status: ShiftSessionStatus.fromValue(json['status'] as String?),
      planBlocks: (json['planBlocks'] as List?)
              ?.whereType<Map>()
              .map(
                (item) => ShiftSessionPlanBlock.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(growable: false) ??
          const [],
      isTaxiMode: json['isTaxiMode'] as bool? ?? false,
    );
  }

  ShiftSessionEntity copyWith({
    String? id,
    DateTime? startedAt,
    DateTime? endedAt,
    DateTime? pausedAt,
    Duration? accumulatedPause,
    String? vehicleId,
    ShiftSessionStatus? status,
    List<ShiftSessionPlanBlock>? planBlocks,
    bool? isTaxiMode,
    bool clearPausedAt = false,
    bool clearEndedAt = false,
  }) {
    return ShiftSessionEntity(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: clearEndedAt ? null : (endedAt ?? this.endedAt),
      pausedAt: clearPausedAt ? null : (pausedAt ?? this.pausedAt),
      accumulatedPause: accumulatedPause ?? this.accumulatedPause,
      vehicleId: vehicleId ?? this.vehicleId,
      status: status ?? this.status,
      planBlocks: planBlocks ?? this.planBlocks,
      isTaxiMode: isTaxiMode ?? this.isTaxiMode,
    );
  }
}
