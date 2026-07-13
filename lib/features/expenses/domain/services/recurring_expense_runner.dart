import '../../domain/entities/recurring_expense_template.dart';

/// Lógica pura para decidir quais templates recorrentes estão vencidos.
abstract final class RecurringExpenseRunner {
  static String monthKeyFor(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  static List<RecurringExpenseTemplate> dueTemplates({
    required List<RecurringExpenseTemplate> templates,
    required DateTime now,
  }) {
    final monthKey = monthKeyFor(now);

    return templates
        .where(
          (template) =>
              template.enabled &&
              template.amount > 0 &&
              now.day >= template.dayOfMonth &&
              template.lastAppliedMonth != monthKey,
        )
        .toList(growable: false);
  }
}
