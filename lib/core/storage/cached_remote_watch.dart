import 'dart:async';

/// Emite cache local primeiro e mantém sincronizado com stream remoto.
///
/// Se o cache local estiver vazio, **não** emite `[]` até o [refresh] terminar
/// (ou falhar). Assim o router não trata “ainda carregando” como “sem dados”.
Stream<List<T>> watchCachedRemote<T>({
  required Stream<List<Map<String, dynamic>>> remote,
  required Future<List<T>> Function() loadLocal,
  required List<T> Function(List<Map<String, dynamic>> rows) mapRows,
  required Future<void> Function(List<Map<String, dynamic>> rows) persistRemote,
  Future<void> Function()? refresh,
}) {
  late StreamSubscription<List<Map<String, dynamic>>> subscription;
  final controller = StreamController<List<T>>();
  var emitted = false;

  Future<void> emitLocal() async {
    if (controller.isClosed) return;
    controller.add(await loadLocal());
    emitted = true;
  }

  controller.onListen = () async {
    final local = await loadLocal();

    subscription = remote.listen(
      (rows) async {
        await persistRemote(rows);
        if (!controller.isClosed) {
          controller.add(mapRows(rows));
          emitted = true;
        }
      },
      onError: (_) async {
        if (!emitted) await emitLocal();
      },
    );

    if (local.isNotEmpty) {
      if (!controller.isClosed) {
        controller.add(local);
        emitted = true;
      }
      if (refresh != null) {
        unawaited(() async {
          try {
            await refresh();
            await emitLocal();
          } catch (_) {}
        }());
      }
      return;
    }

    // Cache frio (ex.: pós-login) — aguarda refresh antes de emitir lista vazia.
    if (refresh != null) {
      try {
        await refresh();
      } catch (_) {}
    }
    if (!emitted) await emitLocal();
  };

  controller.onCancel = () {
    subscription.cancel();
    controller.close();
  };

  return controller.stream;
}
