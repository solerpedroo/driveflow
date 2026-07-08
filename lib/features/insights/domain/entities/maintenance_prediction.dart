import '../../../maintenance/domain/entities/maintenance_entity.dart';

/// Confiança da previsão com base na amostra de km/dia.
enum PredictionConfidence {
  low('Baixa'),
  medium('Média'),
  high('Alta');

  const PredictionConfidence(this.label);

  final String label;
}

/// Previsão de vencimento de manutenção.
class MaintenancePrediction {
  const MaintenancePrediction({
    required this.record,
    required this.predictedDueDate,
    required this.predictedDueKm,
    required this.daysUntilDue,
    required this.kmUntilDue,
    required this.confidence,
    required this.averageKmPerDay,
  });

  final MaintenanceEntity record;
  final DateTime? predictedDueDate;
  final double? predictedDueKm;
  final int? daysUntilDue;
  final double? kmUntilDue;
  final PredictionConfidence confidence;
  final double? averageKmPerDay;

  bool get isActionable =>
      predictedDueDate != null || predictedDueKm != null;

  String get summaryLabel {
    if (daysUntilDue != null && daysUntilDue! <= 14) {
      return '${record.type.label} em ~$daysUntilDue dias';
    }
    if (kmUntilDue != null && kmUntilDue! <= 500) {
      return '${record.type.label} em ~${kmUntilDue!.toStringAsFixed(0)} km';
    }
    if (daysUntilDue != null) {
      return '${record.type.label} em ~$daysUntilDue dias';
    }
    return record.type.label;
  }
}
