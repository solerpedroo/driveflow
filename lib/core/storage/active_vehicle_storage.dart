import 'package:hive_flutter/hive_flutter.dart';

import 'hive_boxes.dart';

/// Persiste o veículo ativo selecionado pelo motorista (escopo de UI).
abstract final class ActiveVehicleStorage {
  static const _activeVehicleIdKey = 'active_vehicle_id';

  static Box<dynamic> get _box => Hive.box<dynamic>(HiveBoxes.appState);

  static String? readActiveVehicleId() {
    final value = _box.get(_activeVehicleIdKey);
    if (value is String && value.isNotEmpty) return value;
    return null;
  }

  static Future<void> writeActiveVehicleId(String? vehicleId) async {
    if (vehicleId == null || vehicleId.isEmpty) {
      await _box.delete(_activeVehicleIdKey);
      return;
    }
    await _box.put(_activeVehicleIdKey, vehicleId);
  }

  static Future<void> clear() => _box.delete(_activeVehicleIdKey);
}
