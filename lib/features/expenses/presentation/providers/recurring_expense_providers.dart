import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../vehicle/presentation/providers/vehicle_providers.dart';
import '../../data/datasources/recurring_expense_storage.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/recurring_expense_template.dart';
import '../../domain/services/recurring_expense_runner.dart';
import 'expenses_providers.dart';

final recurringExpenseTemplatesProvider =
    Provider<List<RecurringExpenseTemplate>>((ref) {
  ref.watch(recurringExpenseTemplatesVersionProvider);
  return RecurringExpenseStorage.readTemplates();
});

final recurringExpenseTemplatesVersionProvider = StateProvider<int>((ref) => 0);

/// Aplica templates vencidos criando despesas no mês corrente.
Future<int> applyDueRecurringExpenses(WidgetRef ref) async {
  final templates = RecurringExpenseStorage.readTemplates();
  final due = RecurringExpenseRunner.dueTemplates(
    templates: templates,
    now: DateTime.now(),
  );
  if (due.isEmpty) return 0;

  final vehicleId = ref.read(scopedVehicleIdProvider) ??
      ref.read(activeVehicleProvider).valueOrNull?.id;
  final monthKey = RecurringExpenseRunner.monthKeyFor(DateTime.now());
  var created = 0;

  for (final template in due) {
    final saved = await ref.read(expensesControllerProvider.notifier).save(
          draft: ExpenseDraft(
            category: template.category,
            amount: template.amount,
            date: DateTime(
              DateTime.now().year,
              DateTime.now().month,
              template.dayOfMonth,
            ),
            description: '${template.label} (recorrente)',
            vehicleId: vehicleId,
          ),
        );
    if (saved == null) continue;

    created++;
    await RecurringExpenseStorage.upsert(
      template.copyWith(lastAppliedMonth: monthKey),
    );
  }

  if (created > 0) {
    ref.read(recurringExpenseTemplatesVersionProvider.notifier).state++;
  }

  return created;
}
