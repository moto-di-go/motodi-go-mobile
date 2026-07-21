class CameroonPhoneValidator {
  static final _nonDigitsExceptPlus = RegExp(r'[^\d+]');

  static String? error(String value) {
    return normalize(value) == null ? 'INVALID_PHONE_NUMBER' : null;
  }

  static String? normalize(String value) {
    var digits = value.trim().replaceAll(' ', '').replaceAll('-', '');
    digits = digits.startsWith('+')
        ? '+${digits.substring(1).replaceAll(RegExp(r'\D'), '')}'
        : digits.replaceAll(_nonDigitsExceptPlus, '');

    String national;
    if (digits.startsWith('+237')) {
      national = digits.substring(4);
    } else if (digits.startsWith('237')) {
      national = digits.substring(3);
    } else {
      national = digits;
    }

    if (RegExp(r'^6\d{8}$').hasMatch(national)) {
      return '+237$national';
    }
    return null;
  }

  static String displayNational(String phoneNumber) {
    final normalized = normalize(phoneNumber);
    final national = normalized?.substring(4) ?? phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (national.length != 9) return phoneNumber;
    return '${national.substring(0, 1)} ${national.substring(1, 3)} '
        '${national.substring(3, 5)} ${national.substring(5, 7)} ${national.substring(7)}';
  }
}

class PasswordValidator {
  static String? error(String value) {
    if (value.length < 8) return 'PASSWORD_TOO_SHORT';
    if (!RegExp(r'\d').hasMatch(value)) return 'PASSWORD_NEEDS_DIGIT';
    return null;
  }

  static PasswordStrength strength(String value) {
    var score = 0;
    if (value.length >= 8) score++;
    if (RegExp(r'\d').hasMatch(value)) score++;
    if (RegExp(r'[A-Z]').hasMatch(value) && RegExp(r'[a-z]').hasMatch(value)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(value)) score++;

    return switch (score) {
      0 || 1 => PasswordStrength.weak,
      2 || 3 => PasswordStrength.medium,
      _ => PasswordStrength.strong,
    };
  }
}

enum PasswordStrength { weak, medium, strong }

class OtpValidator {
  static bool isValid(String value) => RegExp(r'^\d{6}$').hasMatch(value);
}
