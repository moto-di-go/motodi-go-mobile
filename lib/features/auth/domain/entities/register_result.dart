import 'package:equatable/equatable.dart';

class RegisterResult extends Equatable {
  final String userId;
  final String phoneNumber;
  final String status;
  final DateTime otpExpiresAt;

  const RegisterResult({
    required this.userId,
    required this.phoneNumber,
    required this.status,
    required this.otpExpiresAt,
  });

  @override
  List<Object?> get props => [userId, phoneNumber, status, otpExpiresAt];
}

class OtpResult extends Equatable {
  final String userId;
  final String phoneNumber;
  final String status;

  const OtpResult({required this.userId, required this.phoneNumber, required this.status});

  @override
  List<Object?> get props => [userId, phoneNumber, status];
}

class OtpResendResult extends Equatable {
  final String phoneNumber;
  final String purpose;
  final DateTime otpExpiresAt;

  const OtpResendResult({
    required this.phoneNumber,
    required this.purpose,
    required this.otpExpiresAt,
  });

  @override
  List<Object?> get props => [phoneNumber, purpose, otpExpiresAt];
}
