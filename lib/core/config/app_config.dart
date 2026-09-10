import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Central API / env config.
///
/// Priority for [apiBaseUrl]:
/// 1. `--dart-define=API_BASE_URL=...` (device / CI builds)
/// 2. `.env` via flutter_dotenv (emulator `make run-dev`)
/// 3. Android emulator default `http://10.0.2.2:8080/api/v1`
class AppConfig {
  AppConfig._();

  static const String _defaultApiBaseUrl = 'http://10.0.2.2:8080/api/v1';

  static const String _dartDefineApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// Base URL of the API gateway (`.../api/v1`), without trailing slash preference
  /// left to callers that need a normalized form.
  static String get apiBaseUrl {
    if (_dartDefineApiBaseUrl.isNotEmpty) {
      return _dartDefineApiBaseUrl;
    }
    return dotenv.env['API_BASE_URL'] ?? _defaultApiBaseUrl;
  }
}
