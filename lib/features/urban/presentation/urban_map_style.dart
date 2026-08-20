import 'package:flutter_dotenv/flutter_dotenv.dart';

class UrbanMapStyle {
  static const fallbackAsset = 'assets/map/motodigo-style.json';

  static String get url {
    try {
      final value = dotenv.env['MAP_STYLE_URL']?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    } catch (_) {
      // dotenv not loaded (tests).
    }
    return fallbackAsset;
  }
}
