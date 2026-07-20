import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/storage/hive_boxes.dart';
import 'package:driveflow/core/storage/local_entity_cache.dart';
import 'package:driveflow/core/storage/pending_sync_operation.dart';
import 'package:driveflow/core/storage/pending_sync_queue.dart';
import 'support/hive_test_helper.dart';

void main() {
  late Directory tempDir;
  late LocalEntityCache cache;
  late PendingSyncQueue queue;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('driveflow_hive_');
    await openHiveBoxesForTests(path: tempDir.path);
    cache = LocalEntityCache();
    queue = PendingSyncQueue(cache: cache);
  });

  tearDown(() async {
    await closeHiveBoxesForTests();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('LocalEntityCache replaceAll and readAll', () async {
    await cache.replaceAll(HiveBoxes.earnings, [
      {'id': '1', 'amount': 100},
      {'id': '2', 'amount': 50},
    ]);

    final rows = await cache.readAll(HiveBoxes.earnings);
    expect(rows, hasLength(2));
    expect(rows.map((r) => r['id']), containsAll(['1', '2']));
  });

  test('PendingSyncQueue enqueue and dequeue', () async {
    final op = PendingSyncOperation(
      id: 'op1',
      entity: HiveBoxes.earnings,
      action: SyncAction.create,
      entityId: 'local_1',
      payload: {'amount': 10},
      createdAt: DateTime(2026, 7, 8),
    );

    await queue.enqueue(op);
    expect(await queue.pendingCount(), 1);

    final peeked = await queue.peek();
    expect(peeked?.id, 'op1');

    await queue.dequeue('op1');
    expect(await queue.pendingCount(), 0);
  });

  test('PendingSyncOperation backoff grows exponentially', () {
    final op = PendingSyncOperation(
      id: 'op1',
      entity: HiveBoxes.earnings,
      action: SyncAction.create,
      entityId: 'local_1',
      payload: {},
      createdAt: DateTime(2026, 7, 8),
      attempts: 3,
    );

    expect(op.backoffDelay.inSeconds, 8);
  });
}
