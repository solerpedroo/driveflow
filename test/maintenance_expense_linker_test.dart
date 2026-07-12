import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/features/maintenance/domain/services/maintenance_expense_linker.dart';

void main() {
  group('MaintenanceExpenseLinker', () {
    test('description inclui token estável', () {
      final text = MaintenanceExpenseLinker.description(
        maintenanceId: 'm1',
        typeLabel: 'Óleo',
      );

      expect(text, contains('maintenance:m1'));
      expect(text, contains('Óleo'));
    });

    test('matches localiza token na descrição', () {
      expect(
        MaintenanceExpenseLinker.matches(
          'Manutenção — Óleo · maintenance:m1',
          'm1',
        ),
        isTrue,
      );
      expect(
        MaintenanceExpenseLinker.matches('Outra despesa', 'm1'),
        isFalse,
      );
    });
  });
}
