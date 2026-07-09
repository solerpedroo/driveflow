import 'dart:async';

/// Emite cache local primeiro e mantém sincronizado com stream remoto.
Stream<List<T>> watchCachedRemote<T>({
  required Stream<List<Map<String, dynamic>>> remote,
  required Future<List<T>> Function() loadLocal,
  required List<T> Function(List<Map<String, dynamic>> rows) mapRows,
  required Future<void> Function(List<Map<String, dynamic>> rows) persistRemote,
  Future<void> Function()? refresh,
}) {
  late StreamSubscription<List<Map<String, dynamic>>> subscription;
  final controller = StreamController<List<T>>();

  Future<void> emitLocal() async {
    if (controller.isClosed) return;
    controller.add(await loadLocal());
  }

  controller.onListen = () async {
    await emitLocal();
    if (refresh != null) {
      unawaited(() async {
        try {
          await refresh();
          await emitLocal();
        } catch (_) {}
      }());
    }
    subscription = remote.listen(
      (rows) async {
        await persistRemote(rows);
        if (!controller.isClosed) controller.add(mapRows(rows));
      },
      onError: (_) async => emitLocal(),
    );
  };

  controller.onCancel = () {
    subscription.cancel();
    controller.close();
  };

  return controller.stream;
}
