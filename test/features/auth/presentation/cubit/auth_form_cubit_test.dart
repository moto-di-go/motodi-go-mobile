import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:motodi_go_mobile/features/auth/domain/entities/register_result.dart';
import 'package:motodi_go_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/auth_form_cubit.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
  });

  blocTest<AuthFormCubit, AuthFormState>(
    'register rejects invalid phone locally',
    build: () => AuthFormCubit(repository),
    act: (cubit) => cubit.register(
      rawPhoneNumber: '+33678901234',
      fullName: 'Aicha Ngono',
      password: 'password1',
      confirmPassword: 'password1',
      cguAccepted: true,
    ),
    expect: () => [
      isA<AuthFormState>()
          .having((state) => state.status, 'status', AuthFormStatus.failure)
          .having((state) => state.errorCode, 'errorCode', 'INVALID_PHONE_NUMBER'),
    ],
    verify: (_) {
      verifyNever(
        () => repository.register(
          phoneNumber: any(named: 'phoneNumber'),
          password: any(named: 'password'),
          fullName: any(named: 'fullName'),
          cguAccepted: any(named: 'cguAccepted'),
          locale: any(named: 'locale'),
        ),
      );
    },
  );

  blocTest<AuthFormCubit, AuthFormState>(
    'register rejects full name shorter than ten characters locally',
    build: () => AuthFormCubit(repository),
    act: (cubit) => cubit.register(
      rawPhoneNumber: '6 78 90 12 34',
      fullName: 'Aicha',
      password: 'password1',
      confirmPassword: 'password1',
      cguAccepted: true,
    ),
    expect: () => [
      isA<AuthFormState>()
          .having((state) => state.status, 'status', AuthFormStatus.failure)
          .having((state) => state.errorCode, 'errorCode', 'FULL_NAME_TOO_SHORT'),
    ],
    verify: (_) {
      verifyNever(
        () => repository.register(
          phoneNumber: any(named: 'phoneNumber'),
          password: any(named: 'password'),
          fullName: any(named: 'fullName'),
          cguAccepted: any(named: 'cguAccepted'),
          locale: any(named: 'locale'),
        ),
      );
    },
  );

  blocTest<AuthFormCubit, AuthFormState>(
    'register validates full name before password and terms',
    build: () => AuthFormCubit(repository),
    act: (cubit) => cubit.register(
      rawPhoneNumber: '6 78 90 12 34',
      fullName: 'Aicha',
      password: 'short',
      confirmPassword: 'different',
      cguAccepted: false,
    ),
    expect: () => [
      isA<AuthFormState>()
          .having((state) => state.status, 'status', AuthFormStatus.failure)
          .having((state) => state.errorCode, 'errorCode', 'FULL_NAME_TOO_SHORT'),
    ],
  );

  blocTest<AuthFormCubit, AuthFormState>(
    'register normalizes phone and keeps password only in pending in-memory state',
    build: () {
      when(
        () => repository.register(
          phoneNumber: '+237678901234',
          password: 'password1',
          fullName: 'Aicha Ngono',
          cguAccepted: true,
          locale: any(named: 'locale'),
        ),
      ).thenAnswer(
        (_) async => right(
          RegisterResult(
            userId: 'user-1',
            phoneNumber: '+237678901234',
            status: 'OTP_PENDING',
            otpExpiresAt: DateTime(2026, 7, 21, 10),
          ),
        ),
      );
      return AuthFormCubit(repository);
    },
    act: (cubit) => cubit.register(
      rawPhoneNumber: '6 78 90 12 34',
      fullName: 'Aicha Ngono',
      password: 'password1',
      confirmPassword: 'password1',
      cguAccepted: true,
    ),
    expect: () => [
      const AuthFormState(status: AuthFormStatus.loading, phoneNumber: '+237678901234'),
      AuthFormState(
        status: AuthFormStatus.success,
        phoneNumber: '+237678901234',
        pendingPassword: 'password1',
        registerResult: RegisterResult(
          userId: 'user-1',
          phoneNumber: '+237678901234',
          status: 'OTP_PENDING',
          otpExpiresAt: DateTime(2026, 7, 21, 10),
        ),
      ),
    ],
  );

  blocTest<AuthFormCubit, AuthFormState>(
    'verifyRegistrationOtp rejects non-six-digit OTP locally',
    build: () => AuthFormCubit(repository),
    act: (cubit) => cubit.verifyRegistrationOtp(
      phoneNumber: '+237678901234',
      code: '12345',
      password: 'password1',
    ),
    expect: () => [
      isA<AuthFormState>()
          .having((state) => state.status, 'status', AuthFormStatus.failure)
          .having((state) => state.errorCode, 'errorCode', 'OTP_INVALID'),
    ],
  );

  blocTest<AuthFormCubit, AuthFormState>(
    'verifyRegistrationOtp emits authenticated session after repository auto-login',
    build: () {
      when(
        () => repository.verifyRegistrationOtpAndLogin(
          phoneNumber: '+237678901234',
          code: '123456',
          password: 'password1',
        ),
      ).thenAnswer((_) async => right(_session()));
      return AuthFormCubit(repository);
    },
    act: (cubit) => cubit.verifyRegistrationOtp(
      phoneNumber: '+237678901234',
      code: '123456',
      password: 'password1',
    ),
    expect: () => [
      const AuthFormState(status: AuthFormStatus.loading, phoneNumber: '+237678901234'),
      AuthFormState(
        status: AuthFormStatus.success,
        phoneNumber: '+237678901234',
        session: _session(),
      ),
    ],
  );

  blocTest<AuthFormCubit, AuthFormState>(
    'login maps repository failure to form failure',
    build: () {
      when(
        () => repository.login(phoneNumber: '+237678901234', password: 'bad-password'),
      ).thenAnswer(
        (_) async =>
            left(const AuthFailure('Numero ou mot de passe incorrect.', code: 'AUTH_INVALID')),
      );
      return AuthFormCubit(repository);
    },
    act: (cubit) => cubit.login(rawPhoneNumber: '678901234', password: 'bad-password'),
    expect: () => [
      const AuthFormState(status: AuthFormStatus.loading, phoneNumber: '+237678901234'),
      const AuthFormState(
        status: AuthFormStatus.failure,
        phoneNumber: '+237678901234',
        errorCode: 'AUTH_INVALID',
        errorMessage: 'Numero ou mot de passe incorrect.',
      ),
    ],
  );
}

AuthSession _session() {
  return AuthSession(
    tokenType: 'Bearer',
    accessToken: 'access',
    refreshToken: 'refresh',
    accessTokenExpiresAt: DateTime(2026, 7, 21, 11),
    refreshTokenExpiresAt: DateTime(2026, 8, 21, 11),
    sessionId: 'session-1',
    userId: 'user-1',
    phoneNumber: '+237678901234',
    roles: const [],
    profiles: const [],
    permissions: const [],
  );
}
