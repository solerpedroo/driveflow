import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/storage/cached_remote_watch.dart';

void main() {
  test('watchCachedRemote does not emit empty list before refresh completes',
      () async {
    var refreshStarted = false;
    var refreshDone = false;

    final events = <List<String>>[];
    final remote = StreamController<List<Map<String, dynamic>>>();

    final stream = watchCachedRemote<String>(
      remote: remote.stream,
      loadLocal: () async => const <String>[],
      mapRows: (rows) =>
          rows.map((r) => r['id'] as String).toList(growable: false),
      persistRemote: (_) async {},
      refresh: () async {
        refreshStarted = true;
        await Future<void>.delayed(const Duration(milliseconds: 40));
        refreshDone = true;
      },
    );

    final sub = stream.listen(events.add);

    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(refreshStarted, isTrue);
    expect(refreshDone, isFalse);
    expect(events, isEmpty);

    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(refreshDone, isTrue);
    expect(events, [isEmpty]);

    await sub.cancel();
    await remote.close();
  });

  test('watchCachedRemote emits warm cache immediately', () async {
    final events = <List<String>>[];
    final remote = StreamController<List<Map<String, dynamic>>>();

    final stream = watchCachedRemote<String>(
      remote: remote.stream,
      loadLocal: () async => const ['cached'],
      mapRows: (rows) =>
          rows.map((r) => r['id'] as String).toList(growable: false),
      persistRemote: (_) async {},
      refresh: () async {},
    );

    final sub = stream.listen(events.add);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(events.first, ['cached']);

    await sub.cancel();
    await remote.close();
  });
}
