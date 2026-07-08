import '../entities/fuel_log_entity.dart';

abstract interface class FuelRepository {
  Stream<List<FuelLogEntity>> watchFuelLogs({required String vehicleId});

  Future<List<FuelLogEntity>> fetchFuelLogs({required String vehicleId});

  Future<FuelLogEntity> createFuelLog(FuelLogDraft draft);

  Future<FuelLogEntity> updateFuelLog({
    required String id,
    required FuelLogDraft draft,
  });

  Future<void> deleteFuelLog(String id);
}
