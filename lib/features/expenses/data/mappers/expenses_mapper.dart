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

  static Map<String, dynamic> toRow(ExpenseEntity entity) {
    return {
      ExpensesSchema.id: entity.id,
      ExpensesSchema.userId: entity.userId,
      ExpensesSchema.category: entity.category.value,
      ExpensesSchema.amount: entity.amount,
      ExpensesSchema.description: entity.description,
      ExpensesSchema.receiptUrl: entity.receiptUrl,
      ExpensesSchema.date: entity.date.toUtc().toIso8601String(),
      if (entity.createdAt != null)
        ExpensesSchema.createdAt: entity.createdAt!.toUtc().toIso8601String(),
      if (entity.updatedAt != null)
        ExpensesSchema.updatedAt: entity.updatedAt!.toUtc().toIso8601String(),
    };
  }

  static Map<String, dynamic> draftToJson(ExpenseDraft draft) {
    return {
      'category': draft.category.value,
      'amount': draft.amount,
      'description': draft.description,
      'receipt_url': draft.receiptUrl,
      'date': draft.date.toUtc().toIso8601String(),
    };
  }

  static ExpenseDraft draftFromJson(Map<String, dynamic> json) {
    return ExpenseDraft(
      category: ExpenseCategory.fromValue(
        json['category'] as String? ?? ExpenseCategory.other.value,
      ),
      amount: _toDouble(json['amount']) ?? 0,
      description: json['description'] as String?,
      receiptUrl: json['receipt_url'] as String?,
      date: _toDateTime(json['date']) ?? DateTime.now(),
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
