import '../../../fuel/domain/entities/fuel_log_entity.dart';
import '../../../maintenance/domain/entities/maintenance_entity.dart';
import '../entities/maintenance_prediction.dart';
import 'average_km_per_day_calculator.dart';
import 'maintenance_interval_defaults.dart';

/// Previsão de manutenção com base em km/dia e intervalos sugeridos.
abstract final class MaintenancePredictor {
  static const upcomingDaysThreshold = 14;
  static const upcomingKmThreshold = 500;

  static List<MaintenancePrediction> predictAll({
    required List<MaintenanceEntity> records,
    required List<FuelLogEntity> fuelLogs,
    required double currentOdometerKm,
    DateTime? now,
  }) {
    final anchor = _dateOnly(now ?? DateTime.now());
    final kmResult = AverageKmPerDayCalculator.compute(
      fuelLogs: fuelLogs,
      currentOdometerKm: currentOdometerKm,
      now: anchor,
    );

    return records
        .map(
          (record) => predict(
            record: record,
            kmResult: kmResult,
            currentOdometerKm: currentOdometerKm,
            now: anchor,
          ),
        )
        .where((prediction) => prediction.isActionable)
        .toList(growable: false);
  }

  static MaintenancePrediction predict({
    required MaintenanceEntity record,
    required AverageKmPerDayResult kmResult,
    required double currentOdometerKm,
    DateTime? now,
  }) {
    final anchor = _dateOnly(now ?? DateTime.now());
    final defaults = MaintenanceIntervalDefaults.forType(record.type);

    final resolvedTargetKm = record.nextDueKm;
    final kmUntilDue = resolvedTargetKm != null
        ? (resolvedTargetKm - currentOdometerKm).clamp(0.0, double.infinity)
        : null;

    DateTime? predictedDate = record.nextDueDate != null
        ? _dateOnly(record.nextDueDate!)
        : null;

    if (predictedDate == null &&
        kmUntilDue != null &&
        kmResult.averageKmPerDay != null &&
        kmResult.averageKmPerDay! > 0) {
      final daysToDue = (kmUntilDue / kmResult.averageKmPerDay!).ceil();
      predictedDate = anchor.add(Duration(days: daysToDue));
    }

    if (predictedDate == null && record.hasReminder) {
      predictedDate = _dateOnly(record.serviceDate)
          .add(Duration(days: defaults.daysInterval));
    }

    int? daysUntilDue;
    if (predictedDate != null) {
      daysUntilDue = predictedDate.difference(anchor).inDays;
      if (daysUntilDue < 0) daysUntilDue = 0;
    }

    if (!record.hasReminder && predictedDate == null && kmUntilDue == null) {
      return MaintenancePrediction(
        record: record,
        predictedDueDate: null,
        predictedDueKm: null,
        daysUntilDue: null,
        kmUntilDue: null,
        confidence: PredictionConfidence.low,
        averageKmPerDay: kmResult.averageKmPerDay,
      );
    }

    return MaintenancePrediction(
      record: record,
      predictedDueDate: predictedDate,
      predictedDueKm: resolvedTargetKm,
      daysUntilDue: daysUntilDue,
      kmUntilDue: kmUntilDue,
      confidence: _confidenceFor(kmResult.sampleCount),
      averageKmPerDay: kmResult.averageKmPerDay,
    );
  }

  static PredictionConfidence _confidenceFor(int sampleCount) {
    if (sampleCount >= 4) return PredictionConfidence.high;
    if (sampleCount >= 2) return PredictionConfidence.medium;
    return PredictionConfidence.low;
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
