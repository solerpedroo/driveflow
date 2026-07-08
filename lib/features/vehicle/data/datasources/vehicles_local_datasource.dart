import '../../../../core/storage/hive_boxes.dart';
import '../../../../core/storage/local_entity_cache.dart';

/// Cache local de veículos (Hive).
class VehiclesLocalDataSource {
  VehiclesLocalDataSource({LocalEntityCache? cache})
      : _cache = cache ?? LocalEntityCache();

  final LocalEntityCache _cache;

  Future<List<Map<String, dynamic>>> readAll() =>
      _cache.readAll(HiveBoxes.vehicles);

  Future<void> replaceAll(List<Map<String, dynamic>> rows) =>
      _cache.replaceAll(HiveBoxes.vehicles, rows);

  Future<void> upsert(Map<String, dynamic> row) =>
      _cache.upsert(HiveBoxes.vehicles, row);

  Future<void> remove(String id) => _cache.remove(HiveBoxes.vehicles, id);
}
