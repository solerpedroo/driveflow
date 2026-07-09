import '../../../fuel/domain/entities/fuel_log_entity.dart';
import '../../../maintenance/domain/entities/maintenance_entity.dart';
import '../entities/maintenance_prediction.dart';
import 'maintenance_predictor.dart';

/// Reagenda lembretes preditivos após mudança no padrão de uso.
class PredictiveMaintenanceScheduler {
  PredictiveMaintenanceScheduler({
    required this.syncPredictiveReminder,
    required this.cancelReminder,
  });

  final Future<void> Function({
    required MaintenanceEntity record,
    required DateTime predictedDueDate,
    required PredictionConfidence confidence,
  }) syncPredictiveReminder;

  final Future<void> Function(String maintenanceId) cancelReminder;

  Future<void> reschedule({
    required List<MaintenanceEntity> records,
    required List<FuelLogEntity> fuelLogs,
    required double currentOdometerKm,
    DateTime? now,
  }) async {
    final predictions = MaintenancePredictor.predictAll(
      records: records,
      fuelLogs: fuelLogs,
      currentOdometerKm: currentOdometerKm,
      now: now,
    );

    for (final record in records) {
      if (!record.hasReminder) {
        await cancelReminder(record.id);
      }
    }

    for (final prediction in predictions) {
      final dueDate = prediction.predictedDueDate;
      if (dueDate == null) continue;
      if (!prediction.record.hasReminder) continue;

      await syncPredictiveReminder(
        record: prediction.record,
        predictedDueDate: dueDate,
        confidence: prediction.confidence,
      );
    }
  }
}
