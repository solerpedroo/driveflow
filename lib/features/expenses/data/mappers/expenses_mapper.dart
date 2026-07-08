import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/expense_entity.dart';
import '../schema/expenses_schema.dart';

abstract final class ExpensesMapper {
  static ExpenseEntity fromRow(Map<String, dynamic> row) {
    final categoryValue =
        row[ExpensesSchema.category] as String? ?? ExpenseCategory.other.value;
    return ExpenseEntity(
      id: row[ExpensesSchema.id] as String,
      userId: row[ExpensesSchema.userId] as String,
      category: ExpenseCategory.fromValue(categoryValue),
      amount: _toDouble(row[ExpensesSchema.amount]) ?? 0,
      description: row[ExpensesSchema.description] as String?,
      receiptUrl: row[ExpensesSchema.receiptUrl] as String?,
      date: _toDateTime(row[ExpensesSchema.date]) ?? DateTime.now(),
      createdAt: _toDateTime(row[ExpensesSchema.createdAt]),
      updatedAt: _toDateTime(row[ExpensesSchema.updatedAt]),
    );
  }

  static Map<String, dynamic> toInsert({
    required String userId,
    required ExpenseDraft draft,
  }) {
    return {
      ExpensesSchema.userId: userId,
      ExpensesSchema.category: draft.category.value,
      ExpensesSchema.amount: draft.amount,
      ExpensesSchema.description: _nullableText(draft.description),
      ExpensesSchema.receiptUrl: draft.receiptUrl,
      ExpensesSchema.date: draft.date.toUtc().toIso8601String(),
    };
  }

  static Map<String, dynamic> toUpdate(ExpenseDraft draft) {
    return {
      ExpensesSchema.category: draft.category.value,
      ExpensesSchema.amount: draft.amount,
      ExpensesSchema.description: _nullableText(draft.description),
      ExpensesSchema.receiptUrl: draft.receiptUrl,
      ExpensesSchema.date: draft.date.toUtc().toIso8601String(),
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
