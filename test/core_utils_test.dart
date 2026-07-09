import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/utils/currency_formatter.dart';
import 'package:driveflow/core/utils/date_utils.dart';
import 'package:driveflow/core/utils/validators.dart';

void main() {
  group('CurrencyFormatter', () {
    test('format BRL', () {
      expect(CurrencyFormatter.format(4320), contains('4.320'));
    });

    test('formatSigned positive', () {
      expect(CurrencyFormatter.formatSigned(100), startsWith('+'));
    });

    test('tryParse accepts comma decimal', () {
      expect(CurrencyFormatter.tryParse('1.234,56'), 1234.56);
    });
  });

  group('DateUtilsDriveFlow', () {
    test('isSameDay', () {
      final a = DateTime(2026, 7, 8, 10);
      final b = DateTime(2026, 7, 8, 22);
      expect(DateUtilsDriveFlow.isSameDay(a, b), isTrue);
    });

    test('startOfWeek is Monday', () {
      final wednesday = DateTime(2026, 7, 8);
      final start = DateUtilsDriveFlow.startOfWeek(wednesday);
      expect(start.weekday, DateTime.monday);
    });
  });

  group('Validators', () {
    test('email valid', () {
      expect(Validators.email('driver@driveflow.app'), isNull);
    });

    test('email invalid', () {
      expect(Validators.email('invalid'), isNotNull);
    });

    test('password min length and complexity', () {
      expect(Validators.password('123'), isNotNull);
      expect(Validators.password('12345678'), isNotNull);
      expect(Validators.password('abc12345'), isNotNull);
      expect(Validators.password('Abc12345'), isNull);
    });

    test('brlAmount rejects invalid value', () {
      expect(Validators.brlAmount(''), isNotNull);
      expect(Validators.brlAmount('R\$ 10,00'), isNull);
    });

    test('odometer rejects value below previous', () {
      expect(Validators.odometer('40000', previous: 45000), isNotNull);
      expect(Validators.odometer('46000', previous: 45000), isNull);
    });
  });
}
