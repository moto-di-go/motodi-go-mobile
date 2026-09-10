import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/core/config/app_config.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/core/network/network_info.dart';
import 'package:motodi_go_mobile/features/auth/data/models/api_error_model.dart';
import 'package:motodi_go_mobile/features/nfc/domain/entities/nfc_entities.dart';
import 'package:motodi_go_mobile/features/nfc/domain/repositories/nfc_repository.dart';
import 'package:motodi_go_mobile/features/offline/data/datasources/offline_remote_datasource.dart';
import 'package:motodi_go_mobile/features/offline/data/db/offline_local_store.dart';
import 'package:motodi_go_mobile/features/offline/domain/entities/offline_entities.dart';
import 'package:motodi_go_mobile/features/offline/domain/repositories/offline_repository.dart';
import 'package:path/path.dart' as p;

@LazySingleton(as: OfflineRepository)
class OfflineRepositoryImpl implements OfflineRepository {
  final OfflineRemoteDataSource _remote;
  final OfflineLocalStore _local;
  final NfcRepository _nfcRepository;
  final NetworkInfo _networkInfo;
  final http.Client _http;

  OfflineRepositoryImpl(
    this._remote,
    this._local,
    this._nfcRepository,
    this._networkInfo,
  ) : _http = http.Client();

  @override
  Future<List<OfflineOperation>> listLocalOperations({bool pendingOnly = false}) {
    return _local.listOperations(pendingOnly: pendingOnly);
  }

  @override
  Future<OfflineOperation> enqueue({
    required OfflineOperationType type,
    required Map<String, dynamic> payload,
    String? idempotencyKey,
  }) {
    return _local.enqueue(
      type: type,
      payload: payload,
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  Future<Either<Failure, List<OfflineMapArea>>> getMapAreas() {
    return _guard(() async {
      final remote = await _remote.getMapAreas();
      final local = await _local.listLocalMapAreas();
      final byId = {for (final m in local) m.id: m};
      return remote.map((m) {
        final cached = byId[m.id];
        return m.toEntity(
          localPath: cached?.localPath,
          downloaded: cached?.downloaded ?? false,
        );
      }).toList();
    });
  }

  @override
  Future<Either<Failure, OfflineMapArea>> downloadMapArea(
    OfflineMapArea area, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      final downloadUrl = _resolveDownloadUrl(area.downloadUrl);
      if (downloadUrl.isEmpty) {
        return left(const ServerFailure('URL de téléchargement manquante.'));
      }
      final request = http.Request('GET', Uri.parse(downloadUrl));
      final response = await _http.send(request);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return left(
          ServerFailure(
            'Téléchargement impossible (${response.statusCode}).',
            code: 'MAP_DOWNLOAD_FAILED',
          ),
        );
      }

      final dir = await _local.mapsDirectory();
      final ext = p.extension(Uri.parse(downloadUrl).path);
      final file = File(p.join(dir.path, '${area.id}${ext.isEmpty ? '.mbtiles' : ext}'));
      final sink = file.openWrite();
      final total = response.contentLength ?? area.sizeBytes;
      var received = 0;

      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) onProgress?.call((received / total).clamp(0.0, 1.0));
      }
      await sink.close();

      final saved = area.copyWith(
        downloaded: true,
        localPath: file.path,
        sizeBytes: await file.length(),
        downloadProgress: 1,
      );
      await _local.upsertMapArea(saved);
      return right(saved);
    } catch (e) {
        return left(
          const ServerFailure(
            'Téléchargement impossible. Vérifiez votre connexion.',
            code: 'MAP_DOWNLOAD_FAILED',
          ),
        );
    }
  }

  /// Remappe les hôtes Docker / localhost vers l'hôte de l'API
  /// (émulateur = 10.0.2.2, appareil physique = IP LAN via dart-define).
  String _resolveDownloadUrl(String rawUrl) {
    final parsed = Uri.tryParse(rawUrl);
    if (parsed == null || !parsed.hasScheme) return rawUrl;
    final apiBase = AppConfig.apiBaseUrl;
    final apiHost = Uri.tryParse(apiBase)?.host;
    if (apiHost == null || apiHost.isEmpty) return rawUrl;

    final dockerHosts = {'object-storage', 'localhost', '127.0.0.1', 'minio'};
    if (!dockerHosts.contains(parsed.host)) return rawUrl;

    return parsed
        .replace(
          host: apiHost,
          port: parsed.hasPort ? parsed.port : 9000,
        )
        .toString();
  }

  @override
  Future<void> deleteMapArea(String id) => _local.deleteMapArea(id);

  @override
  Future<Either<Failure, OfflineSyncBatchResult>> syncPending() {
    return _guard(() async {
      final localOps = await _local.listOperations(pendingOnly: true);
      final nfcPending = await _nfcRepository.listPending();
      final nfcToSync = nfcPending.where(
        (p) =>
            p.syncStatus == NfcSyncStatus.localStored ||
            p.syncStatus == NfcSyncStatus.pendingSync ||
            p.syncStatus == NfcSyncStatus.conflict,
      );

      final operations = <Map<String, dynamic>>[];
      final trackedLocal = <OfflineOperation>[];

      for (final op in localOps) {
        if (op.type == OfflineOperationType.nfcPayment) continue;
        await _local.updateOperation(op.copyWith(syncStatus: NfcSyncStatus.pendingSync));
        trackedLocal.add(op);
        operations.add({
          'type': op.type.apiValue,
          'idempotencyKey': op.idempotencyKey,
          'payload': op.payload,
          'queuedAt': op.queuedAt.toUtc().toIso8601String(),
        });
      }

      for (final p in nfcToSync) {
        operations.add({
          'type': 'NFC_PAYMENT',
          'idempotencyKey': p.idempotencyKey,
          'payload': {
            'signedToken': p.signedToken,
            if (p.bookingId != null) 'bookingId': p.bookingId,
            if (p.tripId != null) 'tripId': p.tripId,
            'amount': p.amount,
            'currency': p.currency,
          },
          'queuedAt': p.recordedAt.toUtc().toIso8601String(),
        });
      }

      if (operations.isEmpty) {
        await _local.setLastSyncAt(DateTime.now().toUtc());
        return const OfflineSyncBatchResult(batchId: '', status: 'EMPTY', results: []);
      }

      // NFC sync via dedicated path keeps local NFC store consistent.
      if (nfcToSync.isNotEmpty) {
        await _nfcRepository.syncPending(nfcToSync.toList());
      }

      final nonNfc = operations.where((o) => o['type'] != 'NFC_PAYMENT').toList();
      if (nonNfc.isEmpty) {
        await _local.setLastSyncAt(DateTime.now().toUtc());
        return const OfflineSyncBatchResult(batchId: '', status: 'COMPLETED', results: []);
      }

      final model = await _remote.sync(operations: nonNfc);
      final result = model.toEntity();

      for (final item in result.results) {
        OfflineOperation? op;
        for (final o in trackedLocal) {
          if (o.idempotencyKey == item.idempotencyKey) {
            op = o;
            break;
          }
        }
        if (op == null) continue;
        if (item.isSynced) {
          await _local.updateOperation(
            op.copyWith(
              syncStatus: NfcSyncStatus.synced,
              syncedAt: DateTime.now().toUtc(),
              serverOperationId: item.operationId,
            ),
          );
        } else if (item.isConflict) {
          await _local.updateOperation(
            op.copyWith(
              syncStatus: NfcSyncStatus.conflict,
              conflictCode: item.conflictCode,
              conflictMessage: item.message,
              serverOperationId: item.operationId,
            ),
          );
        } else if (item.isFailed) {
          await _local.updateOperation(
            op.copyWith(
              syncStatus: NfcSyncStatus.rejected,
              conflictMessage: item.message,
              serverOperationId: item.operationId,
            ),
          );
        }
      }

      await _local.setLastSyncAt(DateTime.now().toUtc());
      return result;
    });
  }

  @override
  Future<Either<Failure, List<OfflineOperation>>> listRemoteOperations({
    String? status,
    int page = 0,
    int size = 20,
  }) {
    return _guard(() async {
      final pageModel = await _remote.listOperations(status: status, page: page, size: size);
      return pageModel.operations.map((e) => e.toEntity()).toList();
    });
  }

  @override
  Future<OfflineCacheSettings> getSettings() => _local.getSettings();

  @override
  Future<void> saveSettings(OfflineCacheSettings settings) => _local.saveSettings(settings);

  @override
  Future<OfflineStorageUsage> storageUsage() => _local.storageUsage();

  @override
  DateTime? get lastSyncAt => _local.lastSyncAt;

  @override
  Future<void> clearCaches({bool bookings = true, bool receipts = true, bool maps = false}) async {
    await _local.clearCaches(bookings: bookings, receipts: receipts);
    if (maps) {
      final areas = await _local.listLocalMapAreas();
      for (final a in areas) {
        await _local.deleteMapArea(a.id);
      }
    }
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    if (!await _networkInfo.isConnected) {
      return left(const NetworkFailure('Pas de connexion internet.', code: 'NETWORK_OFFLINE'));
    }
    try {
      return right(await action());
    } catch (error) {
      return left(_failureFromException(error));
    }
  }

  Failure _failureFromException(Object error) {
    if (error is ApiException) {
      return switch (error.code) {
        'SESSION_EXPIRED' => AuthFailure(error.message, code: error.code),
        'OFFLINE_VALIDATION_FAILED' || 'VALIDATION_ERROR' =>
          ValidationFailure(error.message, code: error.code),
        _ => ServerFailure(error.message, code: error.code),
      };
    }
    return ServerFailure(error.toString());
  }
}
