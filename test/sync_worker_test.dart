import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:driveflow/core/services/connectivity_service.dart';
import 'package:driveflow/core/services/sync_status.dart';
import 'package:driveflow/core/services/sync_worker.dart';
import 'package:driveflow/core/storage/local_entity_cache.dart';
import 'package:driveflow/core/storage/pending_sync_operation.dart';
import 'package:driveflow/core/storage/pending_sync_queue.dart';
import 'support/hive_test_helper.dart';

class _FakeConnectivity extends ConnectivityService {
  _FakeConnectivity(this._online);

  final bool _online;

  @override
  Future<bool> get isOnline async => _online;

  @override
  Stream<bool> get onOnlineChanged async* {
    yield _online;
  }
}

void main() {
  late LocalEntityCache cache;
  late PendingSyncQueue queue;
  late Directory tempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'http://127.0.0.1:54321',
      anonKey: 'test-anon-key',
    );
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('driveflow_sync_worker_');
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

  group('SyncWorker', () {
    test('processQueue sets offline when disconnected', () async {
      final worker = SyncWorker(connectivity: _FakeConnectivity(false));
      await worker.processQueue();
      expect(worker.status, SyncStatus.offline);
      worker.dispose();
    });

    test('unsupported entity stays in queue after failure', () async {
      final worker = SyncWorker(
        connectivity: _FakeConnectivity(true),
        queue: queue,
        cache: cache,
      );

      await queue.enqueue(
        PendingSyncOperation(
          id: 'op_unsupported',
          entity: 'unsupported_entity',
          action: SyncAction.create,
          entityId: 'local-1',
          payload: const {},
          createdAt: DateTime(2026, 7, 12),
        ),
      );

      await worker.processQueue();

      expect(await queue.pendingCount(), 1);
      final remaining = await queue.peek();
      expect(remaining?.entity, 'unsupported_entity');
      expect(remaining?.attempts, 1);

      worker.dispose();
    });
  });
}
