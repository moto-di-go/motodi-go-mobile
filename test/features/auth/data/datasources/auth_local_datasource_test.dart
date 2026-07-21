import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motodi_go_mobile/core/storage/auth_storage_keys.dart';
import 'package:motodi_go_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:motodi_go_mobile/features/auth/data/models/auth_models.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FlutterSecureStorage secureStorage;
  late SharedPreferences preferences;
  late AuthLocalDataSourceImpl dataSource;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    secureStorage = const FlutterSecureStorage();
    preferences = await SharedPreferences.getInstance();
    dataSource = AuthLocalDataSourceImpl(secureStorage, preferences);
  });

  test('saves and reads the full session snapshot and token keys', () async {
    final session = _sessionModel();

    await dataSource.saveSession(session);

    final storedSession = await dataSource.readSession();
    expect(storedSession?.accessToken, 'access');
    expect(storedSession?.refreshToken, 'refresh');
    expect(storedSession?.activeProfileType, ProfileType.passenger);
    expect(await secureStorage.read(key: AuthStorageKeys.accessToken), 'access');
    expect(await secureStorage.read(key: AuthStorageKeys.refreshToken), 'refresh');
  });

  test('clears token keys', () async {
    await dataSource.saveSession(_sessionModel());

    await dataSource.clearSession();

    expect(await dataSource.readSession(), isNull);
    expect(await secureStorage.read(key: AuthStorageKeys.accessToken), isNull);
    expect(await secureStorage.read(key: AuthStorageKeys.refreshToken), isNull);
  });

  test('stores onboarding and last phone in shared preferences', () async {
    await dataSource.saveOnboardingSeen(true);
    await dataSource.saveLastPhoneNumber('+237678901234');

    expect(dataSource.readOnboardingSeen(), isTrue);
    expect(dataSource.readLastPhoneNumber(), '+237678901234');
  });
}

AuthSessionModel _sessionModel() {
  return AuthSessionModel(
    tokenType: 'Bearer',
    accessToken: 'access',
    refreshToken: 'refresh',
    accessTokenExpiresAt: DateTime(2026, 7, 21, 11),
    refreshTokenExpiresAt: DateTime(2026, 8, 21, 11),
    sessionId: 'session-1',
    userId: 'user-1',
    phoneNumber: '+237678901234',
    roles: const [ProfileType.passenger],
    profiles: const [],
    activeProfileId: 'profile-1',
    activeProfileType: ProfileType.passenger,
    permissions: const ['rides:create'],
  );
}
