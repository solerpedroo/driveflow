import '../../../../core/constants/app_constants.dart';

/// Fatia de despesa por categoria para gráfico de pizza.
class CategoryBreakdownSlice {
  const CategoryBreakdownSlice({
    required this.category,
    required this.amount,
    required this.share,
  });

  final ExpenseCategory category;
  final double amount;
  final double share;
}
