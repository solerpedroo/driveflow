import 'package:hive_flutter/hive_flutter.dart';

import 'hive_boxes.dart';

/// Inicializa Hive e abre todas as boxes do app.
abstract final class HiveStorage {
  static Future<void> initialize() async {
    await Hive.initFlutter();
    for (final name in HiveBoxes.all) {
      if (!Hive.isBoxOpen(name)) {
        await Hive.openBox<dynamic>(name);
      }
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
