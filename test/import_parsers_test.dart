import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/app_constants.dart';
import 'package:driveflow/features/expenses/domain/entities/expense_entity.dart';
import 'package:driveflow/features/import/domain/entities/import_format.dart';
import 'package:driveflow/features/import/domain/services/csv_statement_parser.dart';
import 'package:driveflow/features/import/domain/services/import_deduplicator.dart';
import 'package:driveflow/features/import/domain/services/ofx_statement_parser.dart';

void main() {
  group('CsvStatementParser', () {
    test('mapeia CSV Nubank com débito e crédito', () {
      const csv = '''
Data,Valor,Identificador,Descrição
15/01/2024,-50.00,abc,Posto Shell combustivel
16/01/2024,200.00,def,Pix recebido
''';

      final result = CsvStatementParser.parse(csv);

      expect(result.format, ImportFormat.nubank);
      expect(result.transactions, hasLength(2));
      expect(result.transactions.first.type.label, 'Débito');
      expect(result.transactions.first.suggestedCategory, ExpenseCategory.fuel);
      expect(result.transactions.last.type.label, 'Crédito');
    });
  });

  group('OfxStatementParser', () {
    test('extrai STMTTRN com valor e memo', () {
      const ofx = '''
<OFX>
<STMTTRN>
<DTPOSTED>20240115
<TRNAMT>-35.50
<MEMO>Pedagio sem parar
</STMTTRN>
</OFX>
''';

      final result = OfxStatementParser.parse(ofx);

      expect(result.format, ImportFormat.ofx);
      expect(result.transactions, hasLength(1));
      expect(result.transactions.first.amount, 35.5);
      expect(result.transactions.first.suggestedCategory, ExpenseCategory.toll);
    });
  });

  group('ImportDeduplicator', () {
    test('marca duplicata existente', () {
      final existing = ImportDeduplicator.existingFingerprints(
        expenses: [
          ExpenseEntity(
            id: 'e1',
            userId: 'u1',
            category: ExpenseCategory.other,
            amount: 50,
            date: DateTime(2024, 1, 15),
            description: 'Posto Shell combustivel',
          ),
        ],
        earnings: const [],
      );

      final marked = ImportDeduplicator.markDuplicates(
        transactions: [
          CsvStatementParser.parse('''
Data,Valor,Descrição
15/01/2024,-50.00,Posto Shell combustivel
''').transactions,
        existing: existing,
      );

      expect(marked.first.isDuplicate, isTrue);
      expect(marked.first.selected, isFalse);
    });
  });
}
