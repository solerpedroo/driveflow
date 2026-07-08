import '../../domain/entities/goal_entity.dart';
import '../schema/goals_schema.dart';

abstract final class GoalsMapper {
  static GoalEntity fromRow(Map<String, dynamic> row) {
    return GoalEntity(
      id: row[GoalsSchema.id] as String,
      userId: row[GoalsSchema.userId] as String,
      daily: _toDouble(row[GoalsSchema.daily]) ?? 0,
      weekly: _toDouble(row[GoalsSchema.weekly]) ?? 0,
      monthly: _toDouble(row[GoalsSchema.monthly]) ?? 0,
      yearly: _toDouble(row[GoalsSchema.yearly]) ?? 0,
      createdAt: _toDateTime(row[GoalsSchema.createdAt]),
      updatedAt: _toDateTime(row[GoalsSchema.updatedAt]),
    );
  }

  static Map<String, dynamic> toUpsert({
    required String userId,
    required GoalDraft draft,
  }) {
    return {
      GoalsSchema.userId: userId,
      GoalsSchema.daily: draft.daily,
      GoalsSchema.weekly: draft.weekly,
      GoalsSchema.monthly: draft.monthly,
      GoalsSchema.yearly: draft.yearly,
    };
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
