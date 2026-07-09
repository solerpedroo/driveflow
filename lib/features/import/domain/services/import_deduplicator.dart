import '../../../earnings/domain/entities/earning_entity.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../entities/statement_transaction.dart';

/// Evita duplicatas por data + valor + hash da descrição.
abstract final class ImportDeduplicator {
  static String fingerprint({
    required DateTime date,
    required double amount,
    required String description,
  }) {
    final day = DateTime(date.year, date.month, date.day);
    final normalized = description.trim().toLowerCase();
    return '${day.toIso8601String().split('T').first}|'
        '${amount.toStringAsFixed(2)}|'
        '${normalized.hashCode}';
  }

  static Set<String> existingFingerprints({
    required List<ExpenseEntity> expenses,
    required List<EarningEntity> earnings,
  }) {
    final keys = <String>{};

    for (final expense in expenses) {
      keys.add(
        fingerprint(
          date: expense.date,
          amount: expense.amount,
          description: expense.description ?? expense.category.label,
        ),
      );
    }

    for (final earning in earnings) {
      keys.add(
        fingerprint(
          date: earning.date,
          amount: earning.amount,
          description: earning.note ?? earning.platform.label,
        ),
      );
    }

    return keys;
  }

  static List<StatementTransaction> markDuplicates({
    required List<StatementTransaction> transactions,
    required Set<String> existing,
  }) {
    final seen = <String>{...existing};

    return transactions
        .map((transaction) {
          final key = fingerprint(
            date: transaction.date,
            amount: transaction.amount,
            description: transaction.description,
          );
          final duplicate = seen.contains(key);
          seen.add(key);
          return transaction.copyWith(
            isDuplicate: duplicate,
            selected: duplicate ? false : transaction.selected,
          );
        })
        .toList(growable: false);
  }
}
