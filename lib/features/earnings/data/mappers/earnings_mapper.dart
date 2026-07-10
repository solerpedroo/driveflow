import '../../../../core/constants/ride_platforms.dart';
import '../../../integrations/domain/entities/earning_source.dart';
import '../../domain/entities/earning_entity.dart';
import '../schema/earnings_schema.dart';

abstract final class EarningsMapper {
  static EarningEntity fromRow(Map<String, dynamic> row) {
    final platformValue =
        row[EarningsSchema.platform] as String? ?? RidePlatform.other.value;
    return EarningEntity(
      id: row[EarningsSchema.id] as String,
      userId: row[EarningsSchema.userId] as String,
      platform: RidePlatform.fromValue(platformValue),
      amount: _toDouble(row[EarningsSchema.amount]) ?? 0,
      rides: (row[EarningsSchema.rides] as num?)?.toInt() ?? 0,
      workedHours: _toDouble(row[EarningsSchema.workedHours]) ?? 0,
      note: row[EarningsSchema.note] as String?,
      date: _toDateTime(row[EarningsSchema.date]) ?? DateTime.now(),
      vehicleId: row[EarningsSchema.vehicleId] as String?,
      source: EarningSource.fromValue(row[EarningsSchema.source] as String?),
      externalId: row[EarningsSchema.externalId] as String?,
      createdAt: _toDateTime(row[EarningsSchema.createdAt]),
      updatedAt: _toDateTime(row[EarningsSchema.updatedAt]),
    );
  }

  static Map<String, dynamic> toInsert({
    required String userId,
    required EarningDraft draft,
  }) {
    return {
      EarningsSchema.userId: userId,
      EarningsSchema.platform: draft.platform.value,
      EarningsSchema.amount: draft.amount,
      EarningsSchema.rides: draft.rides,
      EarningsSchema.workedHours: draft.workedHours,
      EarningsSchema.note: _nullableText(draft.note),
      EarningsSchema.date: draft.date.toUtc().toIso8601String(),
      EarningsSchema.source: draft.source.value,
      if (draft.vehicleId != null) EarningsSchema.vehicleId: draft.vehicleId,
      if (draft.externalId != null) EarningsSchema.externalId: draft.externalId,
    };
  }

  static Map<String, dynamic> toUpdate(EarningDraft draft) {
    return {
      EarningsSchema.platform: draft.platform.value,
      EarningsSchema.amount: draft.amount,
      EarningsSchema.rides: draft.rides,
      EarningsSchema.workedHours: draft.workedHours,
      EarningsSchema.note: _nullableText(draft.note),
      EarningsSchema.date: draft.date.toUtc().toIso8601String(),
      EarningsSchema.source: draft.source.value,
      if (draft.vehicleId != null) EarningsSchema.vehicleId: draft.vehicleId,
      if (draft.externalId != null) EarningsSchema.externalId: draft.externalId,
    };
  }

  static Map<String, dynamic> toRow(EarningEntity entity) {
    return {
      EarningsSchema.id: entity.id,
      EarningsSchema.userId: entity.userId,
      EarningsSchema.platform: entity.platform.value,
      EarningsSchema.amount: entity.amount,
      EarningsSchema.rides: entity.rides,
      EarningsSchema.workedHours: entity.workedHours,
      EarningsSchema.note: entity.note,
      EarningsSchema.date: entity.date.toUtc().toIso8601String(),
      if (entity.vehicleId != null) EarningsSchema.vehicleId: entity.vehicleId,
      EarningsSchema.source: entity.source.value,
      if (entity.externalId != null) EarningsSchema.externalId: entity.externalId,
      if (entity.createdAt != null)
        EarningsSchema.createdAt: entity.createdAt!.toUtc().toIso8601String(),
      if (entity.updatedAt != null)
        EarningsSchema.updatedAt: entity.updatedAt!.toUtc().toIso8601String(),
    };
  }

  static Map<String, dynamic> draftToJson(EarningDraft draft) {
    return {
      'platform': draft.platform.value,
      'amount': draft.amount,
      'rides': draft.rides,
      'worked_hours': draft.workedHours,
      'note': draft.note,
      'date': draft.date.toUtc().toIso8601String(),
      'source': draft.source.value,
      if (draft.vehicleId != null) 'vehicle_id': draft.vehicleId,
      if (draft.externalId != null) 'external_id': draft.externalId,
    };
  }

  static EarningDraft draftFromJson(Map<String, dynamic> json) {
    return EarningDraft(
      platform: RidePlatform.fromValue(json['platform'] as String? ?? 'other'),
      amount: _toDouble(json['amount']) ?? 0,
      rides: (json['rides'] as num?)?.toInt() ?? 0,
      workedHours: _toDouble(json['worked_hours']) ?? 0,
      note: json['note'] as String?,
      date: _toDateTime(json['date']) ?? DateTime.now(),
      vehicleId: json['vehicle_id'] as String?,
      source: EarningSource.fromValue(json['source'] as String?),
      externalId: json['external_id'] as String?,
    );
  }

  static String? _nullableText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
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
}
