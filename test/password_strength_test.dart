import 'package:driveflow/core/utils/password_strength.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PasswordStrength', () {
    test('score returns 0 for empty password', () {
      expect(PasswordStrength.score(''), 0);
    });

    test('score increases as requirements are met', () {
      expect(PasswordStrength.score('abc'), 1);
      expect(PasswordStrength.score('abcdefgh'), 2);
      expect(PasswordStrength.score('Abcdefgh'), 3);
      expect(PasswordStrength.score('Abcdefg1'), 4);
    });

    test('validate returns null for strong password', () {
      expect(PasswordStrength.validate('Abcdefg1'), isNull);
    });

    test('validate rejects missing uppercase', () {
      expect(
        PasswordStrength.validate('abcdefg1'),
        'Inclua pelo menos uma letra maiúscula',
      );
    });

    test('validate rejects missing digit', () {
      expect(
        PasswordStrength.validate('Abcdefgh'),
        'Inclua pelo menos um número',
      );
    });
  });
}
