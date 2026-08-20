import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/core/network/network_info.dart';
import 'package:motodi_go_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:motodi_go_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:motodi_go_mobile/features/auth/data/models/api_error_model.dart';
import 'package:motodi_go_mobile/features/auth/data/models/auth_models.dart';
import 'package:motodi_go_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockAuthRemoteDataSource remote;
  late MockAuthLocalDataSource local;
  late MockNetworkInfo network;
  late AuthRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_sessionModel());
  });

  setUp(() {
    remote = MockAuthRemoteDataSource();
    local = MockAuthLocalDataSource();
    network = MockNetworkInfo();
    repository = AuthRepositoryImpl(remote, local, network);
  });

  group('register', () {
    test('returns NetworkFailure without calling remote when offline', () async {
      when(() => network.isConnected).thenAnswer((_) async => false);

      final result = await repository.register(
        phoneNumber: '+237678901234',
        password: 'password1',
        fullName: 'Aicha Ngono',
        cguAccepted: true,
      );

      expect(result.isLeft(), isTrue);
      result.fold((failure) => expect(failure, isA<NetworkFailure>()), (_) => fail('no data'));
      verifyNever(
        () => remote.register(
          phoneNumber: any(named: 'phoneNumber'),
          password: any(named: 'password'),
          fullName: any(named: 'fullName'),
          cguAccepted: any(named: 'cguAccepted'),
          locale: any(named: 'locale'),
        ),
      );
    });
  });

  group('verifyRegistrationOtpAndLogin', () {
    test('verifies OTP, logs in automatically and stores the session', () async {
      when(() => network.isConnected).thenAnswer((_) async => true);
      when(
        () =>
            remote.verifyOtp(phoneNumber: '+237678901234', code: '123456', purpose: 'REGISTRATION'),
      ).thenAnswer(
        (_) async => const OtpVerifyResponseModel(
          userId: 'user-1',
          phoneNumber: '+237678901234',
          status: 'ACTIVE',
        ),
      );
      when(
        () => remote.login(phoneNumber: '+237678901234', password: 'password1'),
      ).thenAnswer((_) async => _sessionModel());
      when(() => local.saveSession(any())).thenAnswer((_) async {});
      when(() => local.saveLastPhoneNumber(any())).thenAnswer((_) async {});

      final result = await repository.verifyRegistrationOtpAndLogin(
        phoneNumber: '+237678901234',
        code: '123456',
        password: 'password1',
      );

      expect(result.isRight(), isTrue);
      verify(
        () =>
            remote.verifyOtp(phoneNumber: '+237678901234', code: '123456', purpose: 'REGISTRATION'),
      ).called(1);
      verify(() => remote.login(phoneNumber: '+237678901234', password: 'password1')).called(1);
      verify(() => local.saveSession(any())).called(1);
    });

    test('maps OTP_INVALID to ValidationFailure', () async {
      when(() => network.isConnected).thenAnswer((_) async => true);
      when(
        () => remote.verifyOtp(
          phoneNumber: any(named: 'phoneNumber'),
          code: any(named: 'code'),
          purpose: any(named: 'purpose'),
        ),
      ).thenThrow(const ApiException('OTP_INVALID', 'Invalid OTP'));

      final result = await repository.verifyRegistrationOtpAndLogin(
        phoneNumber: '+237678901234',
        code: '000000',
        password: 'password1',
      );

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.code, 'OTP_INVALID');
      }, (_) => fail('no data'));
      verifyNever(
        () => remote.login(
          phoneNumber: any(named: 'phoneNumber'),
          password: any(named: 'password'),
        ),
      );
    });
  });

  group('bootstrapSession', () {
    test('returns null when no local session exists', () async {
      when(() => local.readSession()).thenAnswer((_) async => null);

      final result = await repository.bootstrapSession();

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('no failure'), (session) => expect(session, isNull));
    });

    test('clears session and returns SESSION_EXPIRED when refresh token is expired', () async {
      when(() => local.readSession()).thenAnswer(
        (_) async => _sessionModel(
          accessTokenExpiresAt: DateTime.now().subtract(const Duration(hours: 2)),
          refreshTokenExpiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
      );
      when(() => local.clearSession()).thenAnswer((_) async {});

      final result = await repository.bootstrapSession();

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect(failure.code, 'SESSION_EXPIRED');
      }, (_) => fail('no data'));
      verify(() => local.clearSession()).called(1);
    });

    test('refreshes a valid local session when online to sync active profile', () async {
      when(() => local.readSession()).thenAnswer((_) async => _sessionModel());
      when(() => network.isConnected).thenAnswer((_) async => true);
      when(() => local.readRefreshToken()).thenAnswer((_) async => 'refresh');
      when(
        () => remote.refresh(refreshToken: 'refresh'),
      ).thenAnswer((_) async => _sessionModel(accessToken: 'synced-access'));
      when(() => local.saveSession(any())).thenAnswer((_) async {});

      final result = await repository.bootstrapSession();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('no failure'),
        (session) => expect(session?.accessToken, 'synced-access'),
      );
      verify(() => remote.refresh(refreshToken: 'refresh')).called(1);
      verify(() => local.saveSession(any())).called(1);
    });
  });

  group('refreshSession', () {
    test('refreshes with stored refresh token and persists the new session', () async {
      when(() => network.isConnected).thenAnswer((_) async => true);
      when(() => local.readRefreshToken()).thenAnswer((_) async => 'refresh');
      when(
        () => remote.refresh(refreshToken: 'refresh'),
      ).thenAnswer((_) async => _sessionModel(accessToken: 'new-access'));
      when(() => local.saveSession(any())).thenAnswer((_) async {});

      final result = await repository.refreshSession();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('no failure'),
        (session) => expect(session.accessToken, 'new-access'),
      );
      verify(() => local.saveSession(any())).called(1);
    });

    test('clears local session when refresh token is missing', () async {
      when(() => network.isConnected).thenAnswer((_) async => true);
      when(() => local.readRefreshToken()).thenAnswer((_) async => null);
      when(() => local.clearSession()).thenAnswer((_) async {});

      final result = await repository.refreshSession();

      expect(result.isLeft(), isTrue);
      result.fold((failure) => expect(failure.code, 'SESSION_EXPIRED'), (_) => fail('no data'));
      verify(() => local.clearSession()).called(1);
    });
  });
}

AuthSessionModel _sessionModel({
  String accessToken = 'access',
  DateTime? accessTokenExpiresAt,
  DateTime? refreshTokenExpiresAt,
}) {
  return AuthSessionModel(
    tokenType: 'Bearer',
    accessToken: accessToken,
    refreshToken: 'refresh',
    accessTokenExpiresAt: accessTokenExpiresAt ?? DateTime.now().add(const Duration(hours: 1)),
    refreshTokenExpiresAt: refreshTokenExpiresAt ?? DateTime.now().add(const Duration(days: 30)),
    sessionId: 'session-1',
    userId: 'user-1',
    phoneNumber: '+237678901234',
    roles: const [ProfileType.passenger],
    profiles: const [],
    activeProfileId: null,
    activeProfileType: null,
    permissions: const [],
  );
}
