import '../../../../core/constants/app_constants.dart';

/// Template de despesa recorrente (aluguel, seguro, IPVA, etc.).
class RecurringExpenseTemplate {
  const RecurringExpenseTemplate({
    required this.id,
    required this.label,
    required this.category,
    required this.amount,
    required this.dayOfMonth,
    this.enabled = false,
    this.lastAppliedMonth,
  });

  final String id;
  final String label;
  final ExpenseCategory category;
  final double amount;
  final int dayOfMonth;
  final bool enabled;
  final String? lastAppliedMonth;

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'category': category.value,
        'amount': amount,
        'dayOfMonth': dayOfMonth,
        'enabled': enabled,
        'lastAppliedMonth': lastAppliedMonth,
      };

  factory RecurringExpenseTemplate.fromJson(Map<String, dynamic> json) {
    return RecurringExpenseTemplate(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      category: ExpenseCategory.fromValue(json['category'] as String? ?? ''),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      dayOfMonth: (json['dayOfMonth'] as num?)?.toInt().clamp(1, 28) ?? 1,
      enabled: json['enabled'] as bool? ?? false,
      lastAppliedMonth: json['lastAppliedMonth'] as String?,
    );
  }

  RecurringExpenseTemplate copyWith({
    String? id,
    String? label,
    ExpenseCategory? category,
    double? amount,
    int? dayOfMonth,
    bool? enabled,
    String? lastAppliedMonth,
    bool clearLastAppliedMonth = false,
  }) {
    return RecurringExpenseTemplate(
      id: id ?? this.id,
      label: label ?? this.label,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      enabled: enabled ?? this.enabled,
      lastAppliedMonth: clearLastAppliedMonth
          ? null
          : (lastAppliedMonth ?? this.lastAppliedMonth),
    );
  }

  static List<RecurringExpenseTemplate> defaults() {
    return const [
      RecurringExpenseTemplate(
        id: 'rent',
        label: 'Aluguel do veículo',
        category: ExpenseCategory.other,
        amount: 0,
        dayOfMonth: 5,
      ),
      RecurringExpenseTemplate(
        id: 'insurance',
        label: 'Seguro',
        category: ExpenseCategory.insurance,
        amount: 0,
        dayOfMonth: 10,
      ),
      RecurringExpenseTemplate(
        id: 'ipva',
        label: 'IPVA',
        category: ExpenseCategory.ipva,
        amount: 0,
        dayOfMonth: 1,
      ),
    ];
  }
}
