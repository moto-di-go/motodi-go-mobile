import 'package:fpdart/fpdart.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:motodi_go_mobile/features/auth/domain/entities/register_result.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthSession?>> bootstrapSession();

  Future<Either<Failure, RegisterResult>> register({
    required String phoneNumber,
    required String password,
    required String fullName,
    required bool cguAccepted,
    String locale,
  });

  Future<Either<Failure, AuthSession>> verifyRegistrationOtpAndLogin({
    required String phoneNumber,
    required String code,
    required String password,
  });

  Future<Either<Failure, OtpResendResult>> resendOtp({
    required String phoneNumber,
    required String purpose,
  });

  Future<Either<Failure, AuthSession>> login({
    required String phoneNumber,
    required String password,
  });

  Future<Either<Failure, AuthSession>> refreshSession();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> forgotPassword(String phoneNumber);

  Future<Either<Failure, void>> resetPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
  });

  Future<void> clearSession();
  String? readLastPhoneNumber();
  bool readOnboardingSeen();
  Future<void> saveOnboardingSeen(bool value);
}
