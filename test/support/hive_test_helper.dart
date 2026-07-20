import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:driveflow/core/storage/hive_boxes.dart';
import 'package:driveflow/core/storage/hive_encryption_key.dart';

/// Abre boxes Hive criptografadas com chave determinística para testes.
Future<void> openHiveBoxesForTests({String? path}) async {
  HiveEncryptionKey.testKeyOverride = List<int>.generate(32, (i) => i + 1);
  Hive.init(path ?? (await Directory.systemTemp.createTemp('df_hive_')).path);

  final cipher = HiveEncryptionKey.cipherFromKey(HiveEncryptionKey.testKeyOverride!);
  for (final name in HiveBoxes.all) {
    if (Hive.isBoxOpen(name)) await Hive.box(name).close();
    try {
      await Hive.openBox<dynamic>(name, encryptionCipher: cipher);
    } on Object {
      await Hive.deleteBoxFromDisk(name);
      await Hive.openBox<dynamic>(name, encryptionCipher: cipher);
    }
  }
}

Future<void> closeHiveBoxesForTests() async {
  HiveEncryptionKey.testKeyOverride = null;
  await Hive.close();
}
