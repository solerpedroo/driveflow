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
}
