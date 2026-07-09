import '../../../../core/constants/app_constants.dart';
import 'import_format.dart';

/// Linha parseada de um extrato bancário.
class StatementTransaction {
  const StatementTransaction({
    required this.lineIndex,
    required this.date,
    required this.description,
    required this.amount,
    required this.type,
    this.suggestedCategory,
    this.selected = true,
    this.isDuplicate = false,
  });

  final int lineIndex;
  final DateTime date;
  final String description;
  final double amount;
  final StatementEntryType type;
  final ExpenseCategory? suggestedCategory;
  final bool selected;
  final bool isDuplicate;

  bool get isCredit => type == StatementEntryType.credit;

  StatementTransaction copyWith({
    int? lineIndex,
    DateTime? date,
    String? description,
    double? amount,
    StatementEntryType? type,
    ExpenseCategory? suggestedCategory,
    bool? selected,
    bool? isDuplicate,
  }) {
    return StatementTransaction(
      lineIndex: lineIndex ?? this.lineIndex,
      date: date ?? this.date,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      suggestedCategory: suggestedCategory ?? this.suggestedCategory,
      selected: selected ?? this.selected,
      isDuplicate: isDuplicate ?? this.isDuplicate,
    );
  }
}

/// Resultado do parse de um arquivo.
class StatementParseResult {
  const StatementParseResult({
    required this.format,
    required this.transactions,
    required this.skippedLines,
  });

  final ImportFormat format;
  final List<StatementTransaction> transactions;
  final int skippedLines;
}

/// Resultado da importação em lote.
class ImportBatchResult {
  const ImportBatchResult({
    required this.importedExpenses,
    required this.importedEarnings,
    required this.skippedDuplicates,
    required this.failed,
  });

  final int importedExpenses;
  final int importedEarnings;
  final int skippedDuplicates;
  final int failed;

  int get totalImported => importedExpenses + importedEarnings;
}
