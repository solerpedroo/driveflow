import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/connectivity_service.dart';
import '../../services/sync_status.dart';
import '../../services/sync_worker.dart';
import '../../storage/local_entity_cache.dart';
import '../../storage/pending_sync_queue.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final localEntityCacheProvider = Provider<LocalEntityCache>((ref) {
  return LocalEntityCache();
});

final pendingSyncQueueProvider = Provider<PendingSyncQueue>((ref) {
  return PendingSyncQueue(cache: ref.watch(localEntityCacheProvider));
});

final syncWorkerProvider = Provider<SyncWorker>((ref) {
  final worker = SyncWorker(
    connectivity: ref.watch(connectivityServiceProvider),
    queue: ref.watch(pendingSyncQueueProvider),
    cache: ref.watch(localEntityCacheProvider),
  );
  ref.onDispose(worker.dispose);
  return worker;
});

final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final worker = ref.watch(syncWorkerProvider);
  return worker.statusStream;
});

final isOnlineProvider = StreamProvider<bool>((ref) {
  return ref.watch(connectivityServiceProvider).onOnlineChanged;
});

final pendingSyncCountProvider = FutureProvider<int>((ref) {
  return ref.watch(pendingSyncQueueProvider).pendingCount();
});
