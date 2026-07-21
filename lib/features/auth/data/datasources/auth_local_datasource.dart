import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/core/storage/auth_storage_keys.dart';
import 'package:motodi_go_mobile/features/auth/data/models/auth_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<AuthSessionModel?> readSession();
  Future<void> saveSession(AuthSessionModel session);
  Future<void> clearSession();
  Future<String?> readRefreshToken();
  Future<void> saveLastPhoneNumber(String phoneNumber);
  String? readLastPhoneNumber();
  bool readOnboardingSeen();
  Future<void> saveOnboardingSeen(bool value);
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _preferences;

  AuthLocalDataSourceImpl(this._secureStorage, this._preferences);

  @override
  Future<AuthSessionModel?> readSession() async {
    final value = await _secureStorage.read(key: AuthStorageKeys.sessionJson);
    if (value == null || value.isEmpty) return null;
    try {
      return AuthSessionModel.fromJsonString(value);
    } catch (_) {
      await clearSession();
      return null;
    }
  }

  @override
  Future<void> saveSession(AuthSessionModel session) async {
    await Future.wait([
      _secureStorage.write(key: AuthStorageKeys.accessToken, value: session.accessToken),
      _secureStorage.write(key: AuthStorageKeys.refreshToken, value: session.refreshToken),
      _secureStorage.write(
        key: AuthStorageKeys.accessTokenExpiresAt,
        value: session.accessTokenExpiresAt.toIso8601String(),
      ),
      _secureStorage.write(
        key: AuthStorageKeys.refreshTokenExpiresAt,
        value: session.refreshTokenExpiresAt.toIso8601String(),
      ),
      _secureStorage.write(key: AuthStorageKeys.sessionId, value: session.sessionId),
      _secureStorage.write(key: AuthStorageKeys.sessionJson, value: session.toJsonString()),
    ]);
  }

  @override
  Future<void> clearSession() async {
    await Future.wait([
      _secureStorage.delete(key: AuthStorageKeys.accessToken),
      _secureStorage.delete(key: AuthStorageKeys.refreshToken),
      _secureStorage.delete(key: AuthStorageKeys.accessTokenExpiresAt),
      _secureStorage.delete(key: AuthStorageKeys.refreshTokenExpiresAt),
      _secureStorage.delete(key: AuthStorageKeys.sessionId),
      _secureStorage.delete(key: AuthStorageKeys.sessionJson),
    ]);
  }

  @override
  Future<String?> readRefreshToken() => _secureStorage.read(key: AuthStorageKeys.refreshToken);

  @override
  Future<void> saveLastPhoneNumber(String phoneNumber) async {
    await _preferences.setString(PreferenceKeys.lastPhoneNumber, phoneNumber);
  }

  @override
  String? readLastPhoneNumber() => _preferences.getString(PreferenceKeys.lastPhoneNumber);

  @override
  bool readOnboardingSeen() => _preferences.getBool(PreferenceKeys.onboardingSeen) ?? false;

  @override
  Future<void> saveOnboardingSeen(bool value) async {
    await _preferences.setBool(PreferenceKeys.onboardingSeen, value);
  }
}
