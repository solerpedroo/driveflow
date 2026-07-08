import '../../../../core/constants/app_constants.dart';
import '../../../expenses/data/datasources/expenses_remote_datasource.dart';
import '../../../expenses/data/schema/expenses_schema.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../vehicle/data/repositories/vehicle_repository_impl.dart';
import '../../domain/entities/fuel_log_entity.dart';
import '../../domain/repositories/fuel_repository.dart';
import '../../domain/services/fuel_expense_linker.dart';
import '../../domain/services/fuel_metrics_calculator.dart';
import '../datasources/fuel_remote_datasource.dart';
import '../mappers/fuel_log_mapper.dart';
import '../schema/fuel_log_schema.dart';

class FuelRepositoryImpl implements FuelRepository {
  FuelRepositoryImpl({
    FuelRemoteDataSource? remote,
    ExpensesRemoteDataSource? expenses,
    VehicleRepositoryImpl? vehicles,
  })  : _remote = remote ?? FuelRemoteDataSource(),
        _expenses = expenses ?? ExpensesRemoteDataSource(),
        _vehicles = vehicles ?? VehicleRepositoryImpl();

  final FuelRemoteDataSource _remote;
  final ExpensesRemoteDataSource _expenses;
  final VehicleRepositoryImpl _vehicles;

  @override
  Stream<List<FuelLogEntity>> watchFuelLogs({required String vehicleId}) {
    return _remote.watchFuelLogs().map(
          (rows) => rows
              .where((row) => row[FuelLogSchema.vehicleId] == vehicleId)
              .map(FuelLogMapper.fromRow)
              .toList(growable: false),
        );
  }

  @override
  Future<List<FuelLogEntity>> fetchFuelLogs({required String vehicleId}) async {
    final rows = await _remote.fetchFuelLogs(vehicleId: vehicleId);
    return rows.map(FuelLogMapper.fromRow).toList(growable: false);
  }

  @override
  Future<FuelLogEntity> createFuelLog(FuelLogDraft draft) async {
    final existing = await fetchFuelLogs(vehicleId: draft.vehicleId);
    final enriched = _withMetrics(draft: draft, existing: existing);

    final row = await _remote.createFuelLog(draft: enriched);
    final entity = FuelLogMapper.fromRow(row);

    await _syncExpense(entity);
    await _vehicles.updateOdometer(
      id: draft.vehicleId,
      odometerKm: draft.odometerKm,
    );

    return entity;
  }

  @override
  Future<FuelLogEntity> updateFuelLog({
    required String id,
    required FuelLogDraft draft,
  }) async {
    final existing = await fetchFuelLogs(vehicleId: draft.vehicleId);
    final enriched = _withMetrics(
      draft: draft,
      existing: existing,
      excludeLogId: id,
    );

    final row = await _remote.updateFuelLog(id: id, draft: enriched);
    final entity = FuelLogMapper.fromRow(row);

    await _syncExpense(entity);
    await _vehicles.updateOdometer(
      id: draft.vehicleId,
      odometerKm: draft.odometerKm,
    );

    return entity;
  }

  @override
  Future<void> deleteFuelLog(String id) async {
    final row = await _remote.fetchFuelLogById(id);
    if (row != null) {
      final entity = FuelLogMapper.fromRow(row);
      await _expenses.deleteByDescriptionContains(
        FuelExpenseLinker.tokenFor(entity.id),
      );
    }
    await _remote.deleteFuelLog(id);
  }

  FuelLogDraft _withMetrics({
    required FuelLogDraft draft,
    required List<FuelLogEntity> existing,
    String? excludeLogId,
  }) {
    final previous = FuelMetricsCalculator.previousOdometer(
      currentOdometerKm: draft.odometerKm,
      existingLogs: existing,
      excludeLogId: excludeLogId,
    );
    final metrics = FuelMetricsCalculator.compute(
      odometerKm: draft.odometerKm,
      liters: draft.liters,
      totalAmount: draft.totalAmount,
      previousOdometerKm: previous,
    );

    return FuelLogDraft(
      vehicleId: draft.vehicleId,
      fuelType: draft.fuelType,
      pricePerLiter: draft.pricePerLiter,
      liters: draft.liters,
      totalAmount: draft.totalAmount,
      odometerKm: draft.odometerKm,
      station: draft.station,
      kmPerLiter: metrics.kmPerLiter,
      costPerKm: metrics.costPerKm,
    );
  }

  Future<void> _syncExpense(FuelLogEntity entity) async {
    final description = FuelExpenseLinker.description(
      fuelLogId: entity.id,
      fuelType: entity.fuelType,
      station: entity.station,
    );
    final token = FuelExpenseLinker.tokenFor(entity.id);
    final existing = await _expenses.findByDescriptionContains(token);
    final date = entity.createdAt ?? DateTime.now();

    if (existing == null) {
      await _expenses.createExpense(
        draft: ExpenseDraft(
          category: ExpenseCategory.fuel,
          amount: entity.totalAmount,
          date: date,
          description: description,
        ),
      );
    } else {
      await _expenses.updateByDescriptionContains(
        token,
        values: {
          ExpensesSchema.amount: entity.totalAmount,
          ExpensesSchema.description: description,
          ExpensesSchema.date: date.toUtc().toIso8601String(),
        },
      );
    }
  }
}
