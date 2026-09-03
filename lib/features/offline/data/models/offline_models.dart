import 'package:motodi_go_mobile/features/offline/domain/entities/offline_entities.dart';

class OfflineMapAreaModel {
  final String id;
  final String areaName;
  final String boundingBoxWkt;
  final int sizeBytes;
  final String downloadUrl;
  final DateTime? expiresAt;
  final bool downloaded;

  const OfflineMapAreaModel({
    required this.id,
    required this.areaName,
    required this.boundingBoxWkt,
    required this.sizeBytes,
    required this.downloadUrl,
    this.expiresAt,
    this.downloaded = false,
  });

  factory OfflineMapAreaModel.fromJson(Map<String, dynamic> json) {
    return OfflineMapAreaModel(
      id: json['id']?.toString() ?? '',
      areaName: json['areaName']?.toString() ?? '',
      boundingBoxWkt: json['boundingBoxWkt']?.toString() ?? '',
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      downloadUrl: json['downloadUrl']?.toString() ?? '',
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? ''),
      downloaded: json['downloaded'] as bool? ?? false,
    );
  }

  OfflineMapArea toEntity({String? localPath, bool? downloaded}) {
    return OfflineMapArea(
      id: id,
      areaName: areaName,
      boundingBoxWkt: boundingBoxWkt,
      sizeBytes: sizeBytes,
      downloadUrl: downloadUrl,
      expiresAt: expiresAt,
      downloaded: downloaded ?? this.downloaded,
      localPath: localPath,
    );
  }
}

class OfflineOperationApiModel {
  final String id;
  final String type;
  final String status;
  final String idempotencyKey;
  final Map<String, dynamic> payload;
  final DateTime? queuedAt;
  final DateTime? syncedAt;
  final String? conflictCode;
  final String? conflictMessage;

  const OfflineOperationApiModel({
    required this.id,
    required this.type,
    required this.status,
    required this.idempotencyKey,
    required this.payload,
    this.queuedAt,
    this.syncedAt,
    this.conflictCode,
    this.conflictMessage,
  });

  factory OfflineOperationApiModel.fromJson(Map<String, dynamic> json) {
    return OfflineOperationApiModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      idempotencyKey: json['idempotencyKey']?.toString() ?? '',
      payload: Map<String, dynamic>.from(json['payload'] as Map? ?? {}),
      queuedAt: DateTime.tryParse(json['queuedAt']?.toString() ?? ''),
      syncedAt: DateTime.tryParse(json['syncedAt']?.toString() ?? ''),
      conflictCode: json['conflictCode']?.toString(),
      conflictMessage: json['conflictMessage']?.toString(),
    );
  }

  OfflineOperation toEntity() {
    final sync = switch (status.toUpperCase()) {
      'SYNCED' || 'IGNORED' => OfflineSyncStatus.synced,
      'CONFLICT' => OfflineSyncStatus.conflict,
      'FAILED' || 'REJECTED' => OfflineSyncStatus.rejected,
      'PENDING' || 'QUEUED' || 'SYNCING' => OfflineSyncStatus.pendingSync,
      _ => OfflineSyncStatus.localStored,
    };
    return OfflineOperation(
      id: id,
      type: OfflineOperationType.fromApi(type),
      syncStatus: sync,
      idempotencyKey: idempotencyKey,
      payload: payload,
      queuedAt: queuedAt ?? DateTime.now().toUtc(),
      syncedAt: syncedAt,
      conflictCode: conflictCode,
      conflictMessage: conflictMessage,
      serverOperationId: id,
    );
  }
}

class OfflineSyncBatchModel {
  final String batchId;
  final String status;
  final List<OfflineSyncItemResult> results;

  const OfflineSyncBatchModel({
    required this.batchId,
    required this.status,
    required this.results,
  });

  factory OfflineSyncBatchModel.fromJson(Map<String, dynamic> json) {
    final resultsRaw = json['results'] as List? ?? const [];
    return OfflineSyncBatchModel(
      batchId: json['batchId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      results: resultsRaw
          .map((e) {
            final m = Map<String, dynamic>.from(e as Map);
            return OfflineSyncItemResult(
              idempotencyKey: m['idempotencyKey']?.toString() ?? '',
              outcome: m['outcome']?.toString() ?? '',
              operationId: m['operationId']?.toString(),
              conflictCode: m['conflictCode']?.toString(),
              message: m['message']?.toString(),
            );
          })
          .toList(),
    );
  }

  OfflineSyncBatchResult toEntity() => OfflineSyncBatchResult(
    batchId: batchId,
    status: status,
    results: results,
  );
}

class OfflineOperationPageModel {
  final List<OfflineOperationApiModel> operations;
  final int page;
  final int size;
  final bool hasMore;

  const OfflineOperationPageModel({
    required this.operations,
    required this.page,
    required this.size,
    required this.hasMore,
  });

  factory OfflineOperationPageModel.fromJson(Map<String, dynamic> json) {
    final ops = json['operations'] as List? ?? const [];
    return OfflineOperationPageModel(
      operations: ops
          .map((e) => OfflineOperationApiModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      page: (json['page'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 20,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}
