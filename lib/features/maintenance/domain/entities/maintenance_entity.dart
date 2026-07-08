import '../../../../core/constants/app_constants.dart';

/// Status de vencimento de uma manutenção.
enum MaintenanceDueStatus {
  ok('Em dia'),
  upcoming('Próximo'),
  overdue('Atrasado');

  const MaintenanceDueStatus(this.label);

  final String label;
}

/// Registro de manutenção veicular.
class MaintenanceEntity {
  const MaintenanceEntity({
    required this.id,
    required this.vehicleId,
    required this.userId,
    required this.type,
    required this.cost,
    required this.serviceDate,
    this.notes,
    this.nextDueKm,
    this.nextDueDate,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String vehicleId;
  final String userId;
  final MaintenanceType type;
  final double cost;
  final DateTime serviceDate;
  final String? notes;
  final double? nextDueKm;
  final DateTime? nextDueDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasReminder => nextDueKm != null || nextDueDate != null;

  MaintenanceEntity copyWith({
    String? id,
    String? vehicleId,
    String? userId,
    MaintenanceType? type,
    double? cost,
    DateTime? serviceDate,
    String? notes,
    double? nextDueKm,
    DateTime? nextDueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaintenanceEntity(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      cost: cost ?? this.cost,
      serviceDate: serviceDate ?? this.serviceDate,
      notes: notes ?? this.notes,
      nextDueKm: nextDueKm ?? this.nextDueKm,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Dados para criar ou atualizar manutenção.
class MaintenanceDraft {
  const MaintenanceDraft({
    required this.vehicleId,
    required this.type,
    required this.cost,
    required this.serviceDate,
    this.notes,
    this.nextDueKm,
    this.nextDueDate,
  });

  final String vehicleId;
  final MaintenanceType type;
  final double cost;
  final DateTime serviceDate;
  final String? notes;
  final double? nextDueKm;
  final DateTime? nextDueDate;
}
