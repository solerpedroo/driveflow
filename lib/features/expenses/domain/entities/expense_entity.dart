import '../../../../core/constants/app_constants.dart';

/// Despesa registrada pelo motorista.
class ExpenseEntity {
  const ExpenseEntity({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    required this.date,
    this.vehicleId,
    this.description,
    this.receiptUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final ExpenseCategory category;
  final double amount;
  final DateTime date;
  final String? vehicleId;
  final String? description;
  final String? receiptUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ExpenseEntity copyWith({
    String? id,
    String? userId,
    ExpenseCategory? category,
    double? amount,
    DateTime? date,
    String? vehicleId,
    String? description,
    String? receiptUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      vehicleId: vehicleId ?? this.vehicleId,
      description: description ?? this.description,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Dados para criar ou atualizar uma despesa.
class ExpenseDraft {
  const ExpenseDraft({
    required this.category,
    required this.amount,
    required this.date,
    this.vehicleId,
    this.description,
    this.receiptUrl,
  });

  final ExpenseCategory category;
  final double amount;
  final DateTime date;
  final String? vehicleId;
  final String? description;
  final String? receiptUrl;
}
