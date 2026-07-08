import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/app_constants.dart';
import 'package:driveflow/features/expenses/data/mappers/expenses_mapper.dart';
import 'package:driveflow/features/expenses/domain/entities/expense_entity.dart';

void main() {
  group('ExpensesMapper', () {
    test('fromRow maps Supabase row to entity', () {
      final entity = ExpensesMapper.fromRow({
        'id': 'x1',
        'user_id': 'u1',
        'category': 'fuel',
        'amount': 180,
        'description': 'Posto Shell',
        'receipt_url': 'https://signed.url/receipt.jpg',
        'date': '2026-07-08T15:00:00Z',
      });

      expect(entity.category, ExpenseCategory.fuel);
      expect(entity.amount, 180);
      expect(entity.description, 'Posto Shell');
      expect(entity.receiptUrl, isNotNull);
    });

    test('toInsert normaliza descrição vazia', () {
      final map = ExpensesMapper.toInsert(
        userId: 'u1',
        draft: ExpenseDraft(
          category: ExpenseCategory.toll,
          amount: 12.5,
          date: DateTime(2026, 7, 8),
          description: '   ',
        ),
      );

      expect(map['category'], ExpenseCategory.toll.value);
      expect(map['description'], isNull);
    });
  });
}
