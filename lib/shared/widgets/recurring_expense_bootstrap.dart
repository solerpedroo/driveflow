import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/expenses/presentation/providers/expenses_providers.dart';
import '../../features/expenses/presentation/providers/recurring_expense_providers.dart';

/// Executa templates recorrentes vencidos ao abrir o app.
class RecurringExpenseBootstrap extends ConsumerStatefulWidget {
  const RecurringExpenseBootstrap({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<RecurringExpenseBootstrap> createState() =>
      _RecurringExpenseBootstrapState();
}

class _RecurringExpenseBootstrapState
    extends ConsumerState<RecurringExpenseBootstrap> {
  var _applied = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(expensesStreamProvider, (previous, next) {
      if (_applied) return;
      next.whenData((_) {
        _applied = true;
        unawaited(applyDueRecurringExpenses(ref));
      });
    });

    return widget.child;
  }
}
