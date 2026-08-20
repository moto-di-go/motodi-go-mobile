import 'dart:convert';

import 'package:motodi_go_mobile/features/urban/data/urban_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UrbanDestinationHistoryStore {
  static const key = 'urban_destination_history_v1';
  static const maxEntries = 8;

  final SharedPreferences _prefs;

  UrbanDestinationHistoryStore(this._prefs);

  List<DestinationHistoryEntry> load() {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((item) => DestinationHistoryEntry.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<DestinationHistoryEntry>> add(DestinationHistoryEntry entry) async {
    final next = [
      entry,
      ...load().where(
        (item) => item.label != entry.label || item.lat != entry.lat || item.lon != entry.lon,
      ),
    ].take(maxEntries).toList();
    await _prefs.setString(key, jsonEncode(next.map((e) => e.toJson()).toList()));
    return next;
  }
}
