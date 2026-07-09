import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/date_range_period.dart';
import '../../../../core/utils/transaction_filters.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../goals/domain/entities/goal_entity.dart';
import '../entities/category_breakdown_slice.dart';

/// Agrupa despesas por categoria com participação percentual.
abstract final class CategoryBreakdownCalculator {
  static List<CategoryBreakdownSlice> build({
    required List<ExpenseEntity> expenses,
    required DateRange range,
  }) {
    final filtered = TransactionFilters.byDateRange(
      expenses,
      range,
      (expense) => expense.date,
    );

    if (filtered.isEmpty) return const [];

    final totals = <ExpenseCategory, double>{};
    for (final expense in filtered) {
      totals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    final grandTotal = totals.values.fold<double>(0, (sum, value) => sum + value);
    if (grandTotal <= 0) return const [];

    final slices = totals.entries
        .map(
          (entry) => CategoryBreakdownSlice(
            category: entry.key,
            amount: entry.value,
            share: entry.value / grandTotal,
          ),
        )
        .toList(growable: false)
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return slices;
  }
}
