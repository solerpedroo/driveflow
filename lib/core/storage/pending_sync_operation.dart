/// Ação de sincronização pendente.
enum SyncAction {
  create('create'),
  update('update'),
  delete('delete');

  const SyncAction(this.value);

  final String value;

  static SyncAction fromValue(String value) {
    return SyncAction.values.firstWhere(
      (a) => a.value == value,
      orElse: () => SyncAction.create,
    );
  }
}

/// Operação enfileirada para replay no Supabase quando online.
class PendingSyncOperation {
  const PendingSyncOperation({
    required this.id,
    required this.entity,
    required this.action,
    required this.entityId,
    required this.payload,
    required this.createdAt,
    this.attempts = 0,
  });

  final String id;
  final String entity;
  final SyncAction action;
  final String entityId;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int attempts;

  Duration get backoffDelay {
    final seconds = 1 << attempts.clamp(0, 6);
    return Duration(seconds: seconds);
  }

  PendingSyncOperation copyWith({
    String? id,
    String? entity,
    SyncAction? action,
    String? entityId,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    int? attempts,
  }) {
    return PendingSyncOperation(
      id: id ?? this.id,
      entity: entity ?? this.entity,
      action: action ?? this.action,
      entityId: entityId ?? this.entityId,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entity': entity,
      'action': action.value,
      'entity_id': entityId,
      'payload': payload,
      'created_at': createdAt.toUtc().toIso8601String(),
      'attempts': attempts,
    };
  }

  factory PendingSyncOperation.fromJson(Map<String, dynamic> json) {
    return PendingSyncOperation(
      id: json['id'] as String,
      entity: json['entity'] as String,
      action: SyncAction.fromValue(json['action'] as String? ?? 'create'),
      entityId: json['entity_id'] as String,
      payload: Map<String, dynamic>.from(json['payload'] as Map? ?? {}),
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
    );
  }
}
