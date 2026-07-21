class RegistrationOtpArgs {
  final String phoneNumber;
  final String password;
  final DateTime expiresAt;

  const RegistrationOtpArgs({
    required this.phoneNumber,
    required this.password,
    required this.expiresAt,
  });
}

class ResetOtpArgs {
  final String phoneNumber;
  final String? code;

  const ResetOtpArgs({required this.phoneNumber, this.code});
}
