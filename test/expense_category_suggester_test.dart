import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/app_constants.dart';
import 'package:driveflow/features/expenses/domain/services/expense_category_suggester.dart';

void main() {
  group('ExpenseCategorySuggester', () {
    test('sugere combustível para texto de posto', () {
      final result = ExpenseCategorySuggester.suggest(
        'POSTO IPIRANGA\nGASOLINA COMUM\nTOTAL R\$ 180,45',
      );

      expect(result?.category, ExpenseCategory.fuel);
      expect(result!.confidence, greaterThan(0.3));
    });

    test('sugere pedágio para sem parar', () {
      final result = ExpenseCategorySuggester.suggest(
        'SEM PARAR\nPEDAGIO SP\nR\$ 12,80',
      );

      expect(result?.category, ExpenseCategory.toll);
    });

    test('retorna null para texto sem palavras-chave', () {
      final result = ExpenseCategorySuggester.suggest('LOJA GENERICA 123');
      expect(result, isNull);
    });
  });
}
