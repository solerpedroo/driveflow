import 'dart:math';

import 'hive_boxes.dart';
import 'local_entity_cache.dart';
import 'pending_sync_operation.dart';

/// Fila persistente de operações offline aguardando sync.
class PendingSyncQueue {
  PendingSyncQueue({LocalEntityCache? cache})
      : _cache = cache ?? LocalEntityCache();

  final LocalEntityCache _cache;
  static const _queueKey = 'queue';

  Future<List<PendingSyncOperation>> readAll() async {
    final box = await _readQueueBox();
    final raw = box[_queueKey];
    if (raw is! List) return [];

    return raw
        .map((item) =>
            PendingSyncOperation.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> enqueue(PendingSyncOperation operation) async {
    final items = await readAll();
    items.add(operation);
    await _writeAll(items);
  }

  Future<PendingSyncOperation?> peek() async {
    final items = await readAll();
    if (items.isEmpty) return null;
    items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return items.first;
  }

  Future<void> dequeue(String operationId) async {
    final items = await readAll();
    items.removeWhere((op) => op.id == operationId);
    await _writeAll(items);
  }

  Future<void> replace(PendingSyncOperation operation) async {
    final items = await readAll();
    final index = items.indexWhere((op) => op.id == operation.id);
    if (index == -1) {
      items.add(operation);
    } else {
      items[index] = operation;
    }
    await _writeAll(items);
  }

  Future<void> removeByEntityId(String entityId) async {
    final items = await readAll();
    items.removeWhere((op) => op.entityId == entityId);
    await _writeAll(items);
  }

  Future<void> updatePayloadForEntity({
    required String entityId,
    required Map<String, dynamic> payload,
  }) async {
    final items = await readAll();
    var changed = false;
    for (var i = 0; i < items.length; i++) {
      if (items[i].entityId == entityId) {
        items[i] = items[i].copyWith(payload: payload);
        changed = true;
      }
    }
    if (changed) await _writeAll(items);
  }

  Future<int> pendingCount() async => (await readAll()).length;

  String generateOperationId() {
    final random = Random();
    return 'op_${DateTime.now().microsecondsSinceEpoch}_${random.nextInt(999999)}';
  }

  Future<Map<dynamic, dynamic>> _readQueueBox() async {
    final rows = await _cache.readAll(HiveBoxes.pendingSyncQueue);
    if (rows.isEmpty) return {};
    return Map<dynamic, dynamic>.from(rows.first);
  }

  Future<void> _writeAll(List<PendingSyncOperation> items) async {
    await _cache.replaceAll(HiveBoxes.pendingSyncQueue, [
      {
        'id': _queueKey,
        _queueKey: items.map((op) => op.toJson()).toList(),
      },
    ]);
  }
}
