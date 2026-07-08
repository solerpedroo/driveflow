import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_remote_datasource.dart';
import '../mappers/vehicle_mapper.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  VehicleRepositoryImpl({VehicleRemoteDataSource? remote})
      : _remote = remote ?? VehicleRemoteDataSource();

  final VehicleRemoteDataSource _remote;

  @override
  Stream<List<VehicleEntity>> watchVehicles() {
    return _remote.watchVehicles().map(
          (rows) => rows.map(VehicleMapper.fromRow).toList(growable: false),
        );
  }

  @override
  Future<List<VehicleEntity>> fetchVehicles() async {
    final rows = await _remote.fetchVehicles();
    return rows.map(VehicleMapper.fromRow).toList(growable: false);
  }

  @override
  Future<VehicleEntity> createVehicle(VehicleDraft draft) async {
    final row = await _remote.createVehicle(draft: draft);
    return VehicleMapper.fromRow(row);
  }

  @override
  Future<VehicleEntity> updateVehicle({
    required String id,
    required VehicleDraft draft,
  }) async {
    final row = await _remote.updateVehicle(id: id, draft: draft);
    return VehicleMapper.fromRow(row);
  }

  @override
  Future<void> deleteVehicle(String id) => _remote.deleteVehicle(id);
}
