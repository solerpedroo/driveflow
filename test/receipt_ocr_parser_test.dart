import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/app_constants.dart';
import 'package:driveflow/features/expenses/domain/services/receipt_ocr_parser.dart';

void main() {
  group('ReceiptOcrParser', () {
    test('extrai total de cupom de posto', () {
      const text = '''
POSTO BR MANIA
CNPJ 12.345.678/0001-90
DATA: 05/07/2026
GASOLINA COMUM
TOTAL R\$ 215,30
''';

      final result = ReceiptOcrParser.parse(text);

      expect(result.amount, 215.30);
      expect(result.amountConfidence, greaterThan(0.8));
      expect(result.date?.day, 5);
      expect(result.date?.month, 7);
      expect(result.date?.year, 2026);
      expect(result.suggestedCategory, ExpenseCategory.fuel);
    });

    test('extrai valor de nota fiscal genérica', () {
      const text = '''
PADARIA DO JOAO
10/06/2026
CAFE DA MANHA
VALOR PAGO 18,50
''';

      final result = ReceiptOcrParser.parse(text);

      expect(result.amount, 18.50);
      expect(result.description, contains('PADARIA'));
      expect(result.suggestedCategory, ExpenseCategory.food);
    });

    test('usa maior valor quando não há linha de total', () {
      const text = '''
ITEM A 10,00
ITEM B 25,90
ITEM C 3,50
''';

      final result = ReceiptOcrParser.parse(text);
      expect(result.amount, 25.90);
      expect(result.amountConfidence, lessThan(0.5));
    });

    test('retorna resultado vazio para texto ilegível', () {
      final result = ReceiptOcrParser.parse('abc xyz');
      expect(result.hasAmount, isFalse);
      expect(result.date, isNull);
    });
  });
}
