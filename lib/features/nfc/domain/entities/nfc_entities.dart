import 'package:equatable/equatable.dart';

/// États locaux / sync — labels FR stricts (jamais « paiement confirmé » avant CONSUMED serveur).
enum NfcSyncStatus {
  localStored,
  pendingSync,
  synced,
  rejected,
  conflict;

  String get labelFr => switch (this) {
    NfcSyncStatus.localStored => 'Enregistré sur ce téléphone',
    NfcSyncStatus.pendingSync => 'En attente de synchronisation',
    NfcSyncStatus.synced => 'Synchronisé',
    NfcSyncStatus.rejected => 'Rejeté',
    NfcSyncStatus.conflict => 'Conflit à résoudre',
  };

  static NfcSyncStatus fromStorage(String? value) {
    return switch (value) {
      'pendingSync' => NfcSyncStatus.pendingSync,
      'synced' => NfcSyncStatus.synced,
      'rejected' => NfcSyncStatus.rejected,
      'conflict' => NfcSyncStatus.conflict,
      _ => NfcSyncStatus.localStored,
    };
  }

  String get storageValue => name;
}

enum NfcTokenStatus {
  issued,
  exchanged,
  pendingSync,
  consumed,
  expired,
  rejected,
  unknown;

  static NfcTokenStatus fromApi(String? value) {
    return switch (value?.toUpperCase()) {
      'ISSUED' => NfcTokenStatus.issued,
      'EXCHANGED' => NfcTokenStatus.exchanged,
      'PENDING_SYNC' => NfcTokenStatus.pendingSync,
      'CONSUMED' => NfcTokenStatus.consumed,
      'EXPIRED' => NfcTokenStatus.expired,
      'REJECTED' => NfcTokenStatus.rejected,
      _ => NfcTokenStatus.unknown,
    };
  }

  String get labelFr => switch (this) {
    NfcTokenStatus.issued => 'Prêt à émettre',
    NfcTokenStatus.exchanged => 'Émis',
    NfcTokenStatus.pendingSync => 'En attente de synchronisation',
    NfcTokenStatus.consumed => 'Synchronisé',
    NfcTokenStatus.expired => 'Expiré',
    NfcTokenStatus.rejected => 'Rejeté',
    NfcTokenStatus.unknown => 'Inconnu',
  };

  bool get isUsable => this == NfcTokenStatus.issued;
}

class NfcEligibility extends Equatable {
  final bool eligible;
  final bool walletActive;
  final double availableBalance;
  final double maxAmount;
  final double? offlineQuotaRemaining;
  final DateTime? offlineQuotaExpiresAt;
  final List<String> reasons;
  final bool deviceNfcSupported;
  final bool forceQrOnly;

  const NfcEligibility({
    required this.eligible,
    required this.walletActive,
    required this.availableBalance,
    required this.maxAmount,
    this.offlineQuotaRemaining,
    this.offlineQuotaExpiresAt,
    this.reasons = const [],
    this.deviceNfcSupported = false,
    this.forceQrOnly = false,
  });

  bool get canPrepare => eligible && availableBalance > 0;

  List<String> get reasonsFr {
    return reasons.map((code) {
      return switch (code) {
        'WALLET_NOT_ACTIVE' => 'Wallet inactif ou gelé',
        'INSUFFICIENT_AVAILABLE_BALANCE' => 'Solde disponible insuffisant',
        _ => code,
      };
    }).toList();
  }

  @override
  List<Object?> get props => [
    eligible,
    walletActive,
    availableBalance,
    maxAmount,
    offlineQuotaRemaining,
    offlineQuotaExpiresAt,
    reasons,
    deviceNfcSupported,
    forceQrOnly,
  ];
}

class NfcPaymentToken extends Equatable {
  final String id;
  final String jti;
  final String signedToken;
  final double amount;
  final String currency;
  final NfcTokenStatus status;
  final String? bookingId;
  final String? tripId;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final DateTime? consumedAt;

  const NfcPaymentToken({
    required this.id,
    required this.jti,
    required this.signedToken,
    required this.amount,
    required this.currency,
    required this.status,
    this.bookingId,
    this.tripId,
    required this.issuedAt,
    required this.expiresAt,
    this.consumedAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get remaining {
    final diff = expiresAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  @override
  List<Object?> get props => [
    id,
    jti,
    signedToken,
    amount,
    currency,
    status,
    bookingId,
    tripId,
    issuedAt,
    expiresAt,
    consumedAt,
  ];
}

class PendingNfcPayment extends Equatable {
  final String id;
  final String signedToken;
  final double amount;
  final String currency;
  final String? bookingId;
  final String? tripId;
  final String? tokenId;
  final NfcSyncStatus syncStatus;
  final String? conflictCode;
  final String? conflictMessage;
  final String idempotencyKey;
  final DateTime recordedAt;
  final bool isInbound;

  const PendingNfcPayment({
    required this.id,
    required this.signedToken,
    required this.amount,
    required this.currency,
    this.bookingId,
    this.tripId,
    this.tokenId,
    required this.syncStatus,
    this.conflictCode,
    this.conflictMessage,
    required this.idempotencyKey,
    required this.recordedAt,
    this.isInbound = true,
  });

  PendingNfcPayment copyWith({
    NfcSyncStatus? syncStatus,
    String? conflictCode,
    String? conflictMessage,
    String? tokenId,
  }) {
    return PendingNfcPayment(
      id: id,
      signedToken: signedToken,
      amount: amount,
      currency: currency,
      bookingId: bookingId,
      tripId: tripId,
      tokenId: tokenId ?? this.tokenId,
      syncStatus: syncStatus ?? this.syncStatus,
      conflictCode: conflictCode,
      conflictMessage: conflictMessage,
      idempotencyKey: idempotencyKey,
      recordedAt: recordedAt,
      isInbound: isInbound,
    );
  }

  @override
  List<Object?> get props => [
    id,
    signedToken,
    amount,
    currency,
    bookingId,
    tripId,
    tokenId,
    syncStatus,
    conflictCode,
    conflictMessage,
    idempotencyKey,
    recordedAt,
    isInbound,
  ];
}

class NfcSyncBatchResult extends Equatable {
  final String batchId;
  final String status;
  final List<NfcSyncItemResult> results;

  const NfcSyncBatchResult({
    required this.batchId,
    required this.status,
    required this.results,
  });

  @override
  List<Object?> get props => [batchId, status, results];
}

class NfcSyncItemResult extends Equatable {
  final String idempotencyKey;
  final String outcome;
  final String? operationId;
  final String? conflictCode;
  final String? message;

  const NfcSyncItemResult({
    required this.idempotencyKey,
    required this.outcome,
    this.operationId,
    this.conflictCode,
    this.message,
  });

  bool get isSynced => outcome.toUpperCase() == 'SYNCED';
  bool get isConflict => outcome.toUpperCase() == 'CONFLICT';
  bool get isFailed => outcome.toUpperCase() == 'FAILED';

  @override
  List<Object?> get props => [idempotencyKey, outcome, operationId, conflictCode, message];
}
