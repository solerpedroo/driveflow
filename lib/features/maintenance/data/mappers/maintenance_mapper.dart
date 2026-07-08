import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../schema/maintenance_schema.dart';

abstract final class MaintenanceMapper {
  static MaintenanceEntity fromRow(Map<String, dynamic> row) {
    final typeValue =
        row[MaintenanceSchema.type] as String? ?? MaintenanceType.oil.value;
    return MaintenanceEntity(
      id: row[MaintenanceSchema.id] as String,
      vehicleId: row[MaintenanceSchema.vehicleId] as String,
      userId: row[MaintenanceSchema.userId] as String,
      type: MaintenanceType.values.firstWhere(
        (t) => t.value == typeValue,
        orElse: () => MaintenanceType.oil,
      ),
      cost: _toDouble(row[MaintenanceSchema.cost]) ?? 0,
      notes: row[MaintenanceSchema.notes] as String?,
      serviceDate:
          _toDateTime(row[MaintenanceSchema.serviceDate]) ?? DateTime.now(),
      nextDueKm: _toDouble(row[MaintenanceSchema.nextDueKm]),
      nextDueDate: _toDateOnly(row[MaintenanceSchema.nextDueDate]),
      createdAt: _toDateTime(row[MaintenanceSchema.createdAt]),
      updatedAt: _toDateTime(row[MaintenanceSchema.updatedAt]),
    );
  }

  static Map<String, dynamic> toInsert({
    required String userId,
    required MaintenanceDraft draft,
  }) {
    return {
      MaintenanceSchema.vehicleId: draft.vehicleId,
      MaintenanceSchema.userId: userId,
      MaintenanceSchema.type: draft.type.value,
      MaintenanceSchema.cost: draft.cost,
      MaintenanceSchema.notes: _nullableText(draft.notes),
      MaintenanceSchema.serviceDate: draft.serviceDate.toUtc().toIso8601String(),
      MaintenanceSchema.nextDueKm: draft.nextDueKm,
      MaintenanceSchema.nextDueDate: _formatDateOnly(draft.nextDueDate),
    };
  }

  static Map<String, dynamic> toUpdate(MaintenanceDraft draft) {
    return {
      MaintenanceSchema.type: draft.type.value,
      MaintenanceSchema.cost: draft.cost,
      MaintenanceSchema.notes: _nullableText(draft.notes),
      MaintenanceSchema.serviceDate: draft.serviceDate.toUtc().toIso8601String(),
      MaintenanceSchema.nextDueKm: draft.nextDueKm,
      MaintenanceSchema.nextDueDate: _formatDateOnly(draft.nextDueDate),
    };
  }

  static String? _nullableText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  static String? _formatDateOnly(DateTime? value) {
    if (value == null) return null;
    final date = DateTime(value.year, value.month, value.day);
    return date.toIso8601String().split('T').first;
  }

  static double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _toDateTime(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value.toLocal();
    return DateTime.tryParse(value.toString())?.toLocal();
  }

  static DateTime? _toDateOnly(Object? value) {
    if (value == null) return null;
    if (value is DateTime) {
      return DateTime(value.year, value.month, value.day);
    }
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }
}
