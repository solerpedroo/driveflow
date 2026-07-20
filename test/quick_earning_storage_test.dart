import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/earnings/data/datasources/quick_earning_storage.dart';
import 'support/hive_test_helper.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('driveflow_quick_earning_');
    await openHiveBoxesForTests(path: tempDir.path);
  });

  tearDown(() async {
    await closeHiveBoxesForTests();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('remember keeps at most 6 unique platform+amount entries', () async {
    for (var i = 0; i < 8; i++) {
      await QuickEarningStorage.remember(
        platform: RidePlatform.uber,
        amount: 10.0 + i,
      );
    }

    final history = QuickEarningStorage.readHistory();
    expect(history, hasLength(6));
    expect(history.first.amount, 17);
  });

  test('remember deduplicates same platform and amount', () async {
    await QuickEarningStorage.remember(
      platform: RidePlatform.ninetyNine,
      amount: 42,
    );
    await QuickEarningStorage.remember(
      platform: RidePlatform.uber,
      amount: 30,
    );
    await QuickEarningStorage.remember(
      platform: RidePlatform.ninetyNine,
      amount: 42,
    );

    final history = QuickEarningStorage.readHistory();
    expect(history, hasLength(2));
    expect(history.first.platform, RidePlatform.ninetyNine);
    expect(history.first.amount, 42);
  });
}
