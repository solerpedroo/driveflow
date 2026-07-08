import 'package:hive/hive.dart';

/// Cache local genérico baseado em Hive (map por id).
class LocalEntityCache {
  Future<List<Map<String, dynamic>>> readAll(String boxName) async {
    final box = Hive.box<dynamic>(boxName);
    return box.values
        .map((value) => Map<String, dynamic>.from(value as Map))
        .toList(growable: false);
  }

  Future<void> replaceAll(
    String boxName,
    List<Map<String, dynamic>> rows,
  ) async {
    final box = Hive.box<dynamic>(boxName);
    await box.clear();
    for (final row in rows) {
      final id = row['id'];
      if (id is String) {
        await box.put(id, row);
      }
    }
  }

  Future<void> upsert(String boxName, Map<String, dynamic> row) async {
    final id = row['id'];
    if (id is! String) return;
    await Hive.box<dynamic>(boxName).put(id, row);
  }

  Future<void> remove(String boxName, String id) async {
    await Hive.box<dynamic>(boxName).delete(id);
  }

  Future<void> replaceId(
    String boxName, {
    required String oldId,
    required Map<String, dynamic> newRow,
  }) async {
    final box = Hive.box<dynamic>(boxName);
    await box.delete(oldId);
    final newId = newRow['id'];
    if (newId is String) {
      await box.put(newId, newRow);
    }
  }
}
