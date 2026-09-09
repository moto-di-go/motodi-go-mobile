import 'package:flutter_test/flutter_test.dart';
import 'package:motodi_go_mobile/features/auth/domain/entities/auth_validators.dart';

void main() {
  group('CameroonPhoneValidator', () {
    test('normalizes spaced national numbers to E.164 Cameroon format', () {
      expect(CameroonPhoneValidator.normalize('6 78 90 12 34'), '+237678901234');
    });

    test('normalizes +237 and 237 prefixed numbers', () {
      expect(CameroonPhoneValidator.normalize('+237 6 78 90 12 34'), '+237678901234');
      expect(CameroonPhoneValidator.normalize('237678901234'), '+237678901234');
    });

    test('rejects non-Cameroon numbers and numbers not starting with 6', () {
      expect(CameroonPhoneValidator.normalize('+33678901234'), isNull);
      expect(CameroonPhoneValidator.normalize('+237578901234'), isNull);
      expect(CameroonPhoneValidator.error('+237578901234'), 'INVALID_PHONE_NUMBER');
    });

    test('formats a normalized number for display as XXX XXX XXX', () {
      expect(CameroonPhoneValidator.displayNational('+237678901234'), '678 901 234');
      expect(CameroonPhoneValidator.formatGroupedNational('678901234'), '678 901 234');
      expect(CameroonPhoneValidator.formatGroupedNational('67890'), '678 90');
    });
  });

  group('PasswordValidator', () {
    test('requires at least eight characters and one digit', () {
      expect(PasswordValidator.error('short1'), 'PASSWORD_TOO_SHORT');
      expect(PasswordValidator.error('password'), 'PASSWORD_NEEDS_DIGIT');
      expect(PasswordValidator.error('password1'), isNull);
    });

    test('computes weak, medium and strong password strengths', () {
      expect(PasswordValidator.strength('abc'), PasswordStrength.weak);
      expect(PasswordValidator.strength('yaounde2024'), PasswordStrength.medium);
      expect(PasswordValidator.strength('Yaounde2024!'), PasswordStrength.strong);
    });
  });

  group('OtpValidator', () {
    test('accepts exactly six digits', () {
      expect(OtpValidator.isValid('123456'), isTrue);
      expect(OtpValidator.isValid('12345'), isFalse);
      expect(OtpValidator.isValid('12345a'), isFalse);
    });
  });
}
