import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/core/storage/hive_boxes.dart';
import 'package:driveflow/features/earnings/data/datasources/quick_earning_storage.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('driveflow_quick_earning_');
    Hive.init(tempDir.path);
    for (final name in HiveBoxes.all) {
      await Hive.openBox<dynamic>(name);
    }
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('remember keeps at most 6 unique platform+amount entries', () async {
    for (var i = 0; i < 8; i++) {
      await QuickEarningStorage.remember(
        platform: RidePlatform.uber,
        amount: 10 + i,
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
