import 'dart:async';
import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:motodi_go_mobile/core/storage/auth_storage_keys.dart';

// Rafraichit le JWT sur 401 sans repasser par Chopper, afin d'eviter une boucle.
class AppAuthenticator extends Authenticator {
  final _storage = const FlutterSecureStorage();

  @override
  FutureOr<Request?> authenticate(
    Request request,
    Response response, [
    Request? originalRequest,
  ]) async {
    if (response.statusCode != 401) return null;

    final refreshToken = await _storage.read(key: AuthStorageKeys.refreshToken);
    if (refreshToken == null) return null;

    final refreshed = await _refreshToken(refreshToken);
    if (refreshed == null) return null;

    final accessToken = refreshed['accessToken'] as String?;
    if (accessToken == null || accessToken.isEmpty) return null;

    await _writeSession(refreshed);
    return applyHeader(originalRequest ?? request, 'Authorization', 'Bearer $accessToken');
  }

  Future<Map<String, dynamic>?> _refreshToken(String refreshToken) async {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080/api/v1';
    final uri = Uri.parse('${baseUrl.replaceFirst(RegExp(r'/$'), '')}/auth/refresh');
    try {
      final response = await http
          .post(
            uri,
            headers: const {'content-type': 'application/json'},
            body: json.encode({'refreshToken': refreshToken}),
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        await _clearSession();
        return null;
      }
      final body = json.decode(response.body);
      return body is Map<String, dynamic> ? body : Map<String, dynamic>.from(body as Map);
    } catch (_) {
      await _clearSession();
      return null;
    }
  }

  Future<void> _writeSession(Map<String, dynamic> json) async {
    await Future.wait([
      _storage.write(key: AuthStorageKeys.accessToken, value: json['accessToken'] as String?),
      _storage.write(key: AuthStorageKeys.refreshToken, value: json['refreshToken'] as String?),
      _storage.write(
        key: AuthStorageKeys.accessTokenExpiresAt,
        value: json['accessTokenExpiresAt'] as String?,
      ),
      _storage.write(
        key: AuthStorageKeys.refreshTokenExpiresAt,
        value: json['refreshTokenExpiresAt'] as String?,
      ),
      _storage.write(key: AuthStorageKeys.sessionId, value: json['sessionId'] as String?),
      _storage.write(key: AuthStorageKeys.sessionJson, value: jsonEncode(json)),
    ]);
  }

  Future<void> _clearSession() async {
    await Future.wait([
      _storage.delete(key: AuthStorageKeys.accessToken),
      _storage.delete(key: AuthStorageKeys.refreshToken),
      _storage.delete(key: AuthStorageKeys.accessTokenExpiresAt),
      _storage.delete(key: AuthStorageKeys.refreshTokenExpiresAt),
      _storage.delete(key: AuthStorageKeys.sessionId),
      _storage.delete(key: AuthStorageKeys.sessionJson),
    ]);
  }
}
