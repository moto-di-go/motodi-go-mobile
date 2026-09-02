import 'package:equatable/equatable.dart';
import 'package:motodi_go_mobile/features/nfc/domain/entities/nfc_entities.dart';

/// Statut connectivité global.
enum ConnectivityStatus { online, offline, weakNetwork }

/// Types d'opérations offline alignés backend.
enum OfflineOperationType {
  bookingCreate,
  bookingCancel,
  nfcPayment,
  profileUpdate,
  supportTicket;

  String get apiValue => switch (this) {
    OfflineOperationType.bookingCreate => 'BOOKING_CREATE',
    OfflineOperationType.bookingCancel => 'BOOKING_CANCEL',
    OfflineOperationType.nfcPayment => 'NFC_PAYMENT',
    OfflineOperationType.profileUpdate => 'PROFILE_UPDATE',
    OfflineOperationType.supportTicket => 'SUPPORT_TICKET',
  };

  String get labelFr => switch (this) {
    OfflineOperationType.bookingCreate => 'Création réservation',
    OfflineOperationType.bookingCancel => 'Annulation réservation',
    OfflineOperationType.nfcPayment => 'Paiement NFC',
    OfflineOperationType.profileUpdate => 'Mise à jour profil',
    OfflineOperationType.supportTicket => 'Ticket support',
  };

  static OfflineOperationType fromApi(String? value) {
    return switch (value?.toUpperCase()) {
      'BOOKING_CREATE' => OfflineOperationType.bookingCreate,
      'BOOKING_CANCEL' => OfflineOperationType.bookingCancel,
      'NFC_PAYMENT' => OfflineOperationType.nfcPayment,
      'PROFILE_UPDATE' => OfflineOperationType.profileUpdate,
      'SUPPORT_TICKET' => OfflineOperationType.supportTicket,
      _ => OfflineOperationType.supportTicket,
    };
  }
}

/// Réutilise les labels FR NFC pour cohérence UI.
typedef OfflineSyncStatus = NfcSyncStatus;

class OfflineOperation extends Equatable {
  final String id;
  final OfflineOperationType type;
  final OfflineSyncStatus syncStatus;
  final String idempotencyKey;
  final Map<String, dynamic> payload;
  final DateTime queuedAt;
  final DateTime? syncedAt;
  final String? conflictCode;
  final String? conflictMessage;
  final String? serverOperationId;

  const OfflineOperation({
    required this.id,
    required this.type,
    required this.syncStatus,
    required this.idempotencyKey,
    required this.payload,
    required this.queuedAt,
    this.syncedAt,
    this.conflictCode,
    this.conflictMessage,
    this.serverOperationId,
  });

  bool get isPending =>
      syncStatus == NfcSyncStatus.localStored ||
      syncStatus == NfcSyncStatus.pendingSync ||
      syncStatus == NfcSyncStatus.conflict;

  OfflineOperation copyWith({
    OfflineSyncStatus? syncStatus,
    DateTime? syncedAt,
    String? conflictCode,
    String? conflictMessage,
    String? serverOperationId,
  }) {
    return OfflineOperation(
      id: id,
      type: type,
      syncStatus: syncStatus ?? this.syncStatus,
      idempotencyKey: idempotencyKey,
      payload: payload,
      queuedAt: queuedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      conflictCode: conflictCode ?? this.conflictCode,
      conflictMessage: conflictMessage ?? this.conflictMessage,
      serverOperationId: serverOperationId ?? this.serverOperationId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    syncStatus,
    idempotencyKey,
    payload,
    queuedAt,
    syncedAt,
    conflictCode,
    conflictMessage,
    serverOperationId,
  ];
}

class OfflineMapArea extends Equatable {
  final String id;
  final String areaName;
  final String boundingBoxWkt;
  final int sizeBytes;
  final String downloadUrl;
  final DateTime? expiresAt;
  final bool downloaded;
  final String? localPath;
  final double? downloadProgress;

  const OfflineMapArea({
    required this.id,
    required this.areaName,
    required this.boundingBoxWkt,
    required this.sizeBytes,
    required this.downloadUrl,
    this.expiresAt,
    this.downloaded = false,
    this.localPath,
    this.downloadProgress,
  });

  OfflineMapArea copyWith({
    bool? downloaded,
    String? localPath,
    double? downloadProgress,
    int? sizeBytes,
  }) {
    return OfflineMapArea(
      id: id,
      areaName: areaName,
      boundingBoxWkt: boundingBoxWkt,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      downloadUrl: downloadUrl,
      expiresAt: expiresAt,
      downloaded: downloaded ?? this.downloaded,
      localPath: localPath ?? this.localPath,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }

  @override
  List<Object?> get props => [
    id,
    areaName,
    boundingBoxWkt,
    sizeBytes,
    downloadUrl,
    expiresAt,
    downloaded,
    localPath,
    downloadProgress,
  ];
}

class OfflineSyncItemResult extends Equatable {
  final String idempotencyKey;
  final String outcome;
  final String? operationId;
  final String? conflictCode;
  final String? message;

  const OfflineSyncItemResult({
    required this.idempotencyKey,
    required this.outcome,
    this.operationId,
    this.conflictCode,
    this.message,
  });

  bool get isSynced => outcome.toUpperCase() == 'SYNCED' || outcome.toUpperCase() == 'IGNORED';
  bool get isConflict => outcome.toUpperCase() == 'CONFLICT';
  bool get isFailed => outcome.toUpperCase() == 'FAILED';

  @override
  List<Object?> get props => [idempotencyKey, outcome, operationId, conflictCode, message];
}

class OfflineSyncBatchResult extends Equatable {
  final String batchId;
  final String status;
  final List<OfflineSyncItemResult> results;

  const OfflineSyncBatchResult({
    required this.batchId,
    required this.status,
    required this.results,
  });

  List<OfflineSyncItemResult> get conflicts => results.where((r) => r.isConflict).toList();

  @override
  List<Object?> get props => [batchId, status, results];
}

class OfflineCacheSettings extends Equatable {
  final int maxCacheMb;
  final bool autoSyncOnReconnect;
  final bool keepReceipts;
  final bool keepBookings;

  const OfflineCacheSettings({
    this.maxCacheMb = 500,
    this.autoSyncOnReconnect = true,
    this.keepReceipts = true,
    this.keepBookings = true,
  });

  OfflineCacheSettings copyWith({
    int? maxCacheMb,
    bool? autoSyncOnReconnect,
    bool? keepReceipts,
    bool? keepBookings,
  }) {
    return OfflineCacheSettings(
      maxCacheMb: maxCacheMb ?? this.maxCacheMb,
      autoSyncOnReconnect: autoSyncOnReconnect ?? this.autoSyncOnReconnect,
      keepReceipts: keepReceipts ?? this.keepReceipts,
      keepBookings: keepBookings ?? this.keepBookings,
    );
  }

  @override
  List<Object?> get props => [maxCacheMb, autoSyncOnReconnect, keepReceipts, keepBookings];
}

class OfflineStorageUsage extends Equatable {
  final int mapsBytes;
  final int cacheBytes;
  final int queueBytes;
  final int maxBytes;

  const OfflineStorageUsage({
    required this.mapsBytes,
    required this.cacheBytes,
    required this.queueBytes,
    required this.maxBytes,
  });

  int get usedBytes => mapsBytes + cacheBytes + queueBytes;

  double get ratio {
    if (maxBytes <= 0) return 0;
    return (usedBytes / maxBytes).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [mapsBytes, cacheBytes, queueBytes, maxBytes];
}
