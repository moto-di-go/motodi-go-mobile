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

  /// Affiche le national camerounais en groupes de 3 : `XXX XXX XXX`.
  static String displayNational(String phoneNumber) {
    final national = nationalDigits(phoneNumber);
    if (national.isEmpty) return phoneNumber;
    return formatGroupedNational(national);
  }

  /// Extrait jusqu'à 9 chiffres nationaux (sans +237).
  static String nationalDigits(String phoneNumber) {
    final normalized = normalize(phoneNumber);
    final raw = normalized?.substring(4) ?? phoneNumber.replaceAll(RegExp(r'\D'), '');
    final withoutCountry = raw.startsWith('237') && raw.length > 9 ? raw.substring(3) : raw;
    return withoutCountry.length > 9 ? withoutCountry.substring(0, 9) : withoutCountry;
  }

  /// Formate des chiffres nationaux en `XXX XXX XXX` (max 9 chiffres).
  static String formatGroupedNational(String digits) {
    final limited = digits.replaceAll(RegExp(r'\D'), '');
    final national = limited.length > 9 ? limited.substring(0, 9) : limited;
    final buffer = StringBuffer();
    for (var i = 0; i < national.length; i++) {
      if (i > 0 && i % 3 == 0) buffer.write(' ');
      buffer.write(national[i]);
    }
    return buffer.toString();
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
