import '../entities/vehicle_entity.dart';

/// Contrato de persistência de veículos.
abstract interface class VehicleRepository {
  Stream<List<VehicleEntity>> watchVehicles();

  Future<List<VehicleEntity>> fetchVehicles();

  Future<VehicleEntity> createVehicle(VehicleDraft draft);

  Future<VehicleEntity> updateVehicle({
    required String id,
    required VehicleDraft draft,
  });

  Future<void> deleteVehicle(String id);

  Future<void> setDefaultVehicle(String id);

  Future<void> setActiveVehicleId(String? vehicleId);

  String? readActiveVehicleId();

  Future<void> updateOdometer({
    required String id,
    required double odometerKm,
  });
}
