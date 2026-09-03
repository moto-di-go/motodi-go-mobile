import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/nfc/domain/entities/nfc_entities.dart';
import 'package:motodi_go_mobile/features/offline/domain/entities/offline_entities.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Stockage local offline (MVP).
/// Tables conceptuelles : offline_operations, map_areas, cached_bookings,
/// cached_receipts, sync_meta. (Drift peut remplacer cette couche plus tard.)
@lazySingleton
class OfflineLocalStore {
  static const _opsKey = 'offline_operations_v1';
  static const _mapsKey = 'offline_map_areas_v1';
  static const _bookingsKey = 'offline_cached_bookings_v1';
  static const _receiptsKey = 'offline_cached_receipts_v1';
  static const _settingsKey = 'offline_cache_settings_v1';
  static const _lastSyncKey = 'offline_last_sync_at_v1';

  final SharedPreferences _prefs;
  final Uuid _uuid = const Uuid();

  OfflineLocalStore(this._prefs);

  Future<List<OfflineOperation>> listOperations({bool pendingOnly = false}) async {
    final all = _readOps();
    if (!pendingOnly) return all;
    return all.where((o) => o.isPending).toList();
  }

  Future<OfflineOperation> enqueue({
    required OfflineOperationType type,
    required Map<String, dynamic> payload,
    String? idempotencyKey,
  }) async {
    final op = OfflineOperation(
      id: _uuid.v4(),
      type: type,
      syncStatus: NfcSyncStatus.localStored,
      idempotencyKey: idempotencyKey ?? _uuid.v4(),
      payload: payload,
      queuedAt: DateTime.now().toUtc(),
    );
    final next = [op, ..._readOps().where((e) => e.id != op.id)];
    await _writeOps(next);
    return op;
  }

  Future<void> updateOperation(OfflineOperation op) async {
    final next = _readOps().map((e) => e.id == op.id ? op : e).toList();
    await _writeOps(next);
  }

  Future<void> removeOperation(String id) async {
    await _writeOps(_readOps().where((e) => e.id != id).toList());
  }

  Future<List<OfflineMapArea>> listLocalMapAreas() async {
    final raw = _prefs.getString(_mapsKey);
    if (raw == null || raw.isEmpty) return const [];
    final list = jsonDecode(raw) as List? ?? const [];
    return list
        .map((e) => _mapFromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> upsertMapArea(OfflineMapArea area) async {
    final current = await listLocalMapAreas();
    final next = [
      area,
      ...current.where((e) => e.id != area.id),
    ];
    await _prefs.setString(
      _mapsKey,
      jsonEncode(next.map(_mapToJson).toList()),
    );
  }

  Future<void> deleteMapArea(String id) async {
    final current = await listLocalMapAreas();
    final target = current.where((e) => e.id == id).firstOrNull;
    if (target?.localPath != null) {
      final file = File(target!.localPath!);
      if (await file.exists()) await file.delete();
    }
    await _prefs.setString(
      _mapsKey,
      jsonEncode(current.where((e) => e.id != id).map(_mapToJson).toList()),
    );
  }

  Future<Directory> mapsDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'offline_maps'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<void> cacheBooking(String id, Map<String, dynamic> json) async {
    final map = _readJsonMap(_bookingsKey);
    map[id] = json;
    await _prefs.setString(_bookingsKey, jsonEncode(map));
  }

  Future<void> cacheReceipt(String id, Map<String, dynamic> json) async {
    final map = _readJsonMap(_receiptsKey);
    map[id] = json;
    await _prefs.setString(_receiptsKey, jsonEncode(map));
  }

  Future<void> clearCaches({required bool bookings, required bool receipts}) async {
    if (bookings) await _prefs.remove(_bookingsKey);
    if (receipts) await _prefs.remove(_receiptsKey);
  }

  Future<OfflineCacheSettings> getSettings() async {
    final raw = _prefs.getString(_settingsKey);
    if (raw == null || raw.isEmpty) return const OfflineCacheSettings();
    final json = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    return OfflineCacheSettings(
      maxCacheMb: (json['maxCacheMb'] as num?)?.toInt() ?? 500,
      autoSyncOnReconnect: json['autoSyncOnReconnect'] as bool? ?? true,
      keepReceipts: json['keepReceipts'] as bool? ?? true,
      keepBookings: json['keepBookings'] as bool? ?? true,
    );
  }

  Future<void> saveSettings(OfflineCacheSettings settings) async {
    await _prefs.setString(
      _settingsKey,
      jsonEncode({
        'maxCacheMb': settings.maxCacheMb,
        'autoSyncOnReconnect': settings.autoSyncOnReconnect,
        'keepReceipts': settings.keepReceipts,
        'keepBookings': settings.keepBookings,
      }),
    );
  }

  DateTime? get lastSyncAt {
    final raw = _prefs.getString(_lastSyncKey);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> setLastSyncAt(DateTime at) async {
    await _prefs.setString(_lastSyncKey, at.toUtc().toIso8601String());
  }

  Future<OfflineStorageUsage> storageUsage() async {
    final settings = await getSettings();
    final maps = await listLocalMapAreas();
    var mapsBytes = 0;
    for (final m in maps) {
      if (m.localPath != null) {
        final f = File(m.localPath!);
        if (await f.exists()) mapsBytes += await f.length();
      } else if (m.downloaded) {
        mapsBytes += m.sizeBytes;
      }
    }
    final bookingsRaw = _prefs.getString(_bookingsKey) ?? '';
    final receiptsRaw = _prefs.getString(_receiptsKey) ?? '';
    final opsRaw = _prefs.getString(_opsKey) ?? '';
    return OfflineStorageUsage(
      mapsBytes: mapsBytes,
      cacheBytes: utf8.encode(bookingsRaw).length + utf8.encode(receiptsRaw).length,
      queueBytes: utf8.encode(opsRaw).length,
      maxBytes: settings.maxCacheMb * 1024 * 1024,
    );
  }

  List<OfflineOperation> _readOps() {
    final raw = _prefs.getString(_opsKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List? ?? const [];
    return list
        .map((e) => _opFromJson(Map<String, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) => b.queuedAt.compareTo(a.queuedAt));
  }

  Future<void> _writeOps(List<OfflineOperation> ops) async {
    await _prefs.setString(
      _opsKey,
      jsonEncode(ops.map(_opToJson).toList()),
    );
  }

  Map<String, dynamic> _readJsonMap(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return {};
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Map<String, dynamic> _opToJson(OfflineOperation op) => {
    'id': op.id,
    'type': op.type.apiValue,
    'syncStatus': op.syncStatus.storageValue,
    'idempotencyKey': op.idempotencyKey,
    'payload': op.payload,
    'queuedAt': op.queuedAt.toUtc().toIso8601String(),
    'syncedAt': op.syncedAt?.toUtc().toIso8601String(),
    'conflictCode': op.conflictCode,
    'conflictMessage': op.conflictMessage,
    'serverOperationId': op.serverOperationId,
  };

  OfflineOperation _opFromJson(Map<String, dynamic> json) {
    return OfflineOperation(
      id: json['id']?.toString() ?? '',
      type: OfflineOperationType.fromApi(json['type']?.toString()),
      syncStatus: NfcSyncStatus.fromStorage(json['syncStatus']?.toString()),
      idempotencyKey: json['idempotencyKey']?.toString() ?? '',
      payload: Map<String, dynamic>.from(json['payload'] as Map? ?? {}),
      queuedAt: DateTime.tryParse(json['queuedAt']?.toString() ?? '') ?? DateTime.now().toUtc(),
      syncedAt: DateTime.tryParse(json['syncedAt']?.toString() ?? ''),
      conflictCode: json['conflictCode']?.toString(),
      conflictMessage: json['conflictMessage']?.toString(),
      serverOperationId: json['serverOperationId']?.toString(),
    );
  }

  Map<String, dynamic> _mapToJson(OfflineMapArea a) => {
    'id': a.id,
    'areaName': a.areaName,
    'boundingBoxWkt': a.boundingBoxWkt,
    'sizeBytes': a.sizeBytes,
    'downloadUrl': a.downloadUrl,
    'expiresAt': a.expiresAt?.toUtc().toIso8601String(),
    'downloaded': a.downloaded,
    'localPath': a.localPath,
  };

  OfflineMapArea _mapFromJson(Map<String, dynamic> json) {
    return OfflineMapArea(
      id: json['id']?.toString() ?? '',
      areaName: json['areaName']?.toString() ?? '',
      boundingBoxWkt: json['boundingBoxWkt']?.toString() ?? '',
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      downloadUrl: json['downloadUrl']?.toString() ?? '',
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? ''),
      downloaded: json['downloaded'] as bool? ?? false,
      localPath: json['localPath']?.toString(),
    );
  }
}
