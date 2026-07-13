import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/app_constants.dart';
import 'package:driveflow/features/expenses/domain/entities/recurring_expense_template.dart';
import 'package:driveflow/features/expenses/domain/services/recurring_expense_runner.dart';

void main() {
  test('dueTemplates returns enabled templates after dayOfMonth', () {
    final templates = [
      const RecurringExpenseTemplate(
        id: 'insurance',
        label: 'Seguro',
        category: ExpenseCategory.insurance,
        amount: 250,
        dayOfMonth: 10,
        enabled: true,
      ),
      const RecurringExpenseTemplate(
        id: 'rent',
        label: 'Aluguel',
        category: ExpenseCategory.other,
        amount: 900,
        dayOfMonth: 15,
        enabled: true,
      ),
      const RecurringExpenseTemplate(
        id: 'ipva',
        label: 'IPVA',
        category: ExpenseCategory.ipva,
        amount: 120,
        dayOfMonth: 1,
        enabled: false,
      ),
    ];

    final due = RecurringExpenseRunner.dueTemplates(
      templates: templates,
      now: DateTime(2026, 7, 12),
    );

    expect(due, hasLength(1));
    expect(due.first.id, 'insurance');
  });

  test('dueTemplates skips templates already applied in the month', () {
    final templates = [
      RecurringExpenseTemplate(
        id: 'insurance',
        label: 'Seguro',
        category: ExpenseCategory.insurance,
        amount: 250,
        dayOfMonth: 5,
        enabled: true,
        lastAppliedMonth: '2026-07',
      ),
    ];

    final due = RecurringExpenseRunner.dueTemplates(
      templates: templates,
      now: DateTime(2026, 7, 20),
    );

    expect(due, isEmpty);
  });

  test('monthKeyFor formats yyyy-mm', () {
    expect(
      RecurringExpenseRunner.monthKeyFor(DateTime(2026, 3, 2)),
      '2026-03',
    );
  });
}
