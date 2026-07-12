import 'package:driveflow/core/utils/csv_escape.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('escapeCsvField', () {
    test('retorna valor simples sem aspas', () {
      expect(escapeCsvField('Uber'), 'Uber');
      expect(escapeCsvField('123.45'), '123.45');
    });

    test('envolve campo com vírgula em aspas', () {
      expect(escapeCsvField('São Paulo, SP'), '"São Paulo, SP"');
    });

    test('duplica aspas internas', () {
      expect(escapeCsvField('diz "oi"'), '"diz ""oi"""');
    });

    test('escapa quebras de linha', () {
      expect(escapeCsvField('linha1\nlinha2'), '"linha1\nlinha2"');
    });
  });

  group('csvRow', () {
    test('junta campos escapados', () {
      expect(
        csvRow(['ganho', '2026-01-01', 'Uber, 99', '42.00']),
        'ganho,2026-01-01,"Uber, 99",42.00',
      );
    });
  });
}
