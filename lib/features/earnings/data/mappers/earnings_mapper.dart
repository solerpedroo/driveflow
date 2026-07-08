import '../../../../core/constants/ride_platforms.dart';
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
    };
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
