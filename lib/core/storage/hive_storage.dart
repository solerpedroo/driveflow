import 'package:hive_flutter/hive_flutter.dart';

import 'hive_boxes.dart';
import 'hive_encryption_key.dart';

/// Inicializa Hive e abre todas as boxes do app (AES-256 em repouso).
abstract final class HiveStorage {
  static Future<void> initialize() async {
    await Hive.initFlutter();
    final key = await HiveEncryptionKey.loadOrCreate();
    final cipher = HiveEncryptionKey.cipherFromKey(key);

    for (final name in HiveBoxes.all) {
      if (!Hive.isBoxOpen(name)) {
        await _openEncryptedBox(name, cipher);
      }
    }
  }

  static Future<void> _openEncryptedBox(String name, HiveAesCipher cipher) async {
    try {
      await Hive.openBox<dynamic>(name, encryptionCipher: cipher);
    } on Object {
      await Hive.deleteBoxFromDisk(name);
      await Hive.openBox<dynamic>(name, encryptionCipher: cipher);
    }
  }

  /// Remove todos os dados locais do usuário (obrigatório no logout).
  static Future<void> clearUserData() async {
    for (final name in HiveBoxes.all) {
      if (Hive.isBoxOpen(name)) {
        await Hive.box<dynamic>(name).clear();
      }
    }
  }
}
