import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/core/network/network_info.dart';
import 'package:motodi_go_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:motodi_go_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:motodi_go_mobile/features/auth/data/models/api_error_model.dart';
import 'package:motodi_go_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:motodi_go_mobile/features/auth/domain/entities/register_result.dart';
import 'package:motodi_go_mobile/features/auth/domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource, this._networkInfo);

  @override
  Future<Either<Failure, AuthSession?>> bootstrapSession() async {
    final session = (await _localDataSource.readSession())?.toEntity();
    if (session == null) return right(null);
    if (session.isRefreshTokenExpired) {
      await _localDataSource.clearSession();
      return left(const AuthFailure('Session expirée.', code: 'SESSION_EXPIRED'));
    }
    if (!session.isAccessTokenExpired) return right(session);
    return refreshSession();
  }

  @override
  Future<Either<Failure, RegisterResult>> register({
    required String phoneNumber,
    required String password,
    required String fullName,
    required bool cguAccepted,
    String locale = 'fr-CM',
  }) async {
    if (!await _networkInfo.isConnected) {
      return left(const NetworkFailure('Pas de connexion internet.', code: 'NETWORK_OFFLINE'));
    }
    try {
      final result = await _remoteDataSource.register(
        phoneNumber: phoneNumber,
        password: password,
        fullName: fullName,
        cguAccepted: cguAccepted,
        locale: locale,
      );
      await _localDataSource.saveLastPhoneNumber(phoneNumber);
      return right(result.toEntity());
    } catch (e) {
      return left(_failureFromException(e));
    }
  }

  @override
  Future<Either<Failure, AuthSession>> verifyRegistrationOtpAndLogin({
    required String phoneNumber,
    required String code,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) {
      return left(const NetworkFailure('Pas de connexion internet.', code: 'NETWORK_OFFLINE'));
    }
    try {
      await _remoteDataSource.verifyOtp(
        phoneNumber: phoneNumber,
        code: code,
        purpose: 'REGISTRATION',
      );
      final session = await _remoteDataSource.login(phoneNumber: phoneNumber, password: password);
      await _localDataSource.saveSession(session);
      await _localDataSource.saveLastPhoneNumber(phoneNumber);
      return right(session.toEntity());
    } catch (e) {
      return left(_failureFromException(e));
    }
  }

  @override
  Future<Either<Failure, OtpResendResult>> resendOtp({
    required String phoneNumber,
    required String purpose,
  }) async {
    if (!await _networkInfo.isConnected) {
      return left(const NetworkFailure('Pas de connexion internet.', code: 'NETWORK_OFFLINE'));
    }
    try {
      final result = await _remoteDataSource.resendOtp(phoneNumber: phoneNumber, purpose: purpose);
      return right(result.toEntity());
    } catch (e) {
      return left(_failureFromException(e));
    }
  }

  @override
  Future<Either<Failure, AuthSession>> login({
    required String phoneNumber,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) {
      return left(const NetworkFailure('Pas de connexion internet.', code: 'NETWORK_OFFLINE'));
    }
    try {
      final session = await _remoteDataSource.login(phoneNumber: phoneNumber, password: password);
      await _localDataSource.saveSession(session);
      await _localDataSource.saveLastPhoneNumber(phoneNumber);
      return right(session.toEntity());
    } catch (e) {
      return left(_failureFromException(e));
    }
  }

  @override
  Future<Either<Failure, AuthSession>> refreshSession() async {
    if (!await _networkInfo.isConnected) {
      return left(const NetworkFailure('Pas de connexion internet.', code: 'NETWORK_OFFLINE'));
    }
    final refreshToken = await _localDataSource.readRefreshToken();
    if (refreshToken == null) {
      await _localDataSource.clearSession();
      return left(const AuthFailure('Session expirée.', code: 'SESSION_EXPIRED'));
    }
    try {
      final session = await _remoteDataSource.refresh(refreshToken: refreshToken);
      await _localDataSource.saveSession(session);
      return right(session.toEntity());
    } catch (e) {
      final failure = _failureFromException(e);
      if (failure is AuthFailure) await _localDataSource.clearSession();
      return left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      if (await _networkInfo.isConnected) {
        await _remoteDataSource.logout();
      }
    } catch (_) {
      // Le logout local reste prioritaire pour eviter une session fantome.
    } finally {
      await _localDataSource.clearSession();
    }
    return right(null);
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String phoneNumber) async {
    if (!await _networkInfo.isConnected) {
      return left(const NetworkFailure('Pas de connexion internet.', code: 'NETWORK_OFFLINE'));
    }
    try {
      await _remoteDataSource.forgotPassword(phoneNumber);
      await _localDataSource.saveLastPhoneNumber(phoneNumber);
      return right(null);
    } catch (e) {
      return left(_failureFromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
  }) async {
    if (!await _networkInfo.isConnected) {
      return left(const NetworkFailure('Pas de connexion internet.', code: 'NETWORK_OFFLINE'));
    }
    try {
      await _remoteDataSource.resetPassword(
        phoneNumber: phoneNumber,
        code: code,
        newPassword: newPassword,
      );
      await _localDataSource.clearSession();
      return right(null);
    } catch (e) {
      return left(_failureFromException(e));
    }
  }

  @override
  Future<void> clearSession() => _localDataSource.clearSession();

  @override
  String? readLastPhoneNumber() => _localDataSource.readLastPhoneNumber();

  @override
  bool readOnboardingSeen() => _localDataSource.readOnboardingSeen();

  @override
  Future<void> saveOnboardingSeen(bool value) => _localDataSource.saveOnboardingSeen(value);

  Failure _failureFromException(Object error) {
    if (error is ApiException) {
      return switch (error.code) {
        'AUTH_INVALID' || 'SESSION_EXPIRED' => AuthFailure(error.message, code: error.code),
        'OTP_INVALID' ||
        'OTP_RATE_LIMITED' ||
        'PHONE_ALREADY_EXISTS' ||
        'INVALID_PHONE_NUMBER' => ValidationFailure(error.message, code: error.code),
        'PASSWORD_RESET_INVALID' ||
        'VALIDATION_FAILED' => ValidationFailure(error.message, code: error.code),
        _ => ServerFailure(error.message, code: error.code),
      };
    }
    return ServerFailure(error.toString());
  }
}
