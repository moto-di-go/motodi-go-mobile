import 'package:motodi_go_mobile/features/nfc/domain/entities/nfc_entities.dart';

double _asDouble(Object? value, [double fallback = 0]) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? fallback;
}

DateTime? _asDate(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value)?.toLocal();
}

class NfcEligibilityModel {
  final bool eligible;
  final bool walletActive;
  final double availableBalance;
  final double maxAmount;
  final double? offlineQuotaRemaining;
  final DateTime? offlineQuotaExpiresAt;
  final List<String> reasons;

  const NfcEligibilityModel({
    required this.eligible,
    required this.walletActive,
    required this.availableBalance,
    required this.maxAmount,
    this.offlineQuotaRemaining,
    this.offlineQuotaExpiresAt,
    this.reasons = const [],
  });

  factory NfcEligibilityModel.fromJson(Map<String, dynamic> json) {
    final rawReasons = json['reasons'] as List? ?? const [];
    return NfcEligibilityModel(
      eligible: json['eligible'] as bool? ?? false,
      walletActive: json['walletActive'] as bool? ?? false,
      availableBalance: _asDouble(json['availableBalance']),
      maxAmount: _asDouble(json['maxAmount']),
      offlineQuotaRemaining: json['offlineQuotaRemaining'] == null
          ? null
          : _asDouble(json['offlineQuotaRemaining']),
      offlineQuotaExpiresAt: _asDate(json['offlineQuotaExpiresAt']),
      reasons: rawReasons.map((e) => e.toString()).toList(),
    );
  }

  NfcEligibility toEntity({required bool deviceNfcSupported, required bool forceQrOnly}) {
    return NfcEligibility(
      eligible: eligible,
      walletActive: walletActive,
      availableBalance: availableBalance,
      maxAmount: maxAmount,
      offlineQuotaRemaining: offlineQuotaRemaining,
      offlineQuotaExpiresAt: offlineQuotaExpiresAt,
      reasons: reasons,
      deviceNfcSupported: deviceNfcSupported,
      forceQrOnly: forceQrOnly,
    );
  }
}

class NfcTokenModel {
  final String id;
  final String jti;
  final String signedToken;
  final double amount;
  final String currency;
  final String status;
  final String? bookingId;
  final String? tripId;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final DateTime? consumedAt;

  const NfcTokenModel({
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

  factory NfcTokenModel.fromJson(Map<String, dynamic> json) {
    return NfcTokenModel(
      id: json['id']?.toString() ?? '',
      jti: json['jti']?.toString() ?? '',
      signedToken: json['signedToken'] as String? ?? '',
      amount: _asDouble(json['amount']),
      currency: json['currency'] as String? ?? 'XAF',
      status: json['status'] as String? ?? 'ISSUED',
      bookingId: json['bookingId']?.toString(),
      tripId: json['tripId']?.toString(),
      issuedAt: _asDate(json['issuedAt']) ?? DateTime.now(),
      expiresAt: _asDate(json['expiresAt']) ?? DateTime.now().add(const Duration(minutes: 5)),
      consumedAt: _asDate(json['consumedAt']),
    );
  }

  NfcPaymentToken toEntity() {
    return NfcPaymentToken(
      id: id,
      jti: jti,
      signedToken: signedToken,
      amount: amount,
      currency: currency,
      status: NfcTokenStatus.fromApi(status),
      bookingId: bookingId,
      tripId: tripId,
      issuedAt: issuedAt,
      expiresAt: expiresAt,
      consumedAt: consumedAt,
    );
  }
}

class NfcSyncBatchModel {
  final String batchId;
  final String status;
  final List<NfcSyncItemModel> results;

  const NfcSyncBatchModel({
    required this.batchId,
    required this.status,
    required this.results,
  });

  factory NfcSyncBatchModel.fromJson(Map<String, dynamic> json) {
    final raw = json['results'] as List? ?? const [];
    return NfcSyncBatchModel(
      batchId: json['batchId']?.toString() ?? '',
      status: json['status'] as String? ?? '',
      results: raw
          .map((item) => NfcSyncItemModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }

  NfcSyncBatchResult toEntity() {
    return NfcSyncBatchResult(
      batchId: batchId,
      status: status,
      results: results.map((e) => e.toEntity()).toList(),
    );
  }
}

class NfcSyncItemModel {
  final String idempotencyKey;
  final String outcome;
  final String? operationId;
  final String? conflictCode;
  final String? message;

  const NfcSyncItemModel({
    required this.idempotencyKey,
    required this.outcome,
    this.operationId,
    this.conflictCode,
    this.message,
  });

  factory NfcSyncItemModel.fromJson(Map<String, dynamic> json) {
    return NfcSyncItemModel(
      idempotencyKey: json['idempotencyKey']?.toString() ?? '',
      outcome: json['outcome'] as String? ?? '',
      operationId: json['operationId']?.toString(),
      conflictCode: json['conflictCode']?.toString(),
      message: json['message']?.toString(),
    );
  }

  NfcSyncItemResult toEntity() {
    return NfcSyncItemResult(
      idempotencyKey: idempotencyKey,
      outcome: outcome,
      operationId: operationId,
      conflictCode: conflictCode,
      message: message,
    );
  }
}

class PendingNfcPaymentModel {
  final String id;
  final String signedToken;
  final double amount;
  final String currency;
  final String? bookingId;
  final String? tripId;
  final String? tokenId;
  final String syncStatus;
  final String? conflictCode;
  final String? conflictMessage;
  final String idempotencyKey;
  final DateTime recordedAt;
  final bool isInbound;

  const PendingNfcPaymentModel({
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

  factory PendingNfcPaymentModel.fromJson(Map<String, dynamic> json) {
    return PendingNfcPaymentModel(
      id: json['id']?.toString() ?? '',
      signedToken: json['signedToken'] as String? ?? '',
      amount: _asDouble(json['amount']),
      currency: json['currency'] as String? ?? 'XAF',
      bookingId: json['bookingId']?.toString(),
      tripId: json['tripId']?.toString(),
      tokenId: json['tokenId']?.toString(),
      syncStatus: json['syncStatus'] as String? ?? NfcSyncStatus.localStored.storageValue,
      conflictCode: json['conflictCode']?.toString(),
      conflictMessage: json['conflictMessage']?.toString(),
      idempotencyKey: json['idempotencyKey']?.toString() ?? '',
      recordedAt: _asDate(json['recordedAt']) ?? DateTime.now(),
      isInbound: json['isInbound'] as bool? ?? true,
    );
  }

  factory PendingNfcPaymentModel.fromEntity(PendingNfcPayment entity) {
    return PendingNfcPaymentModel(
      id: entity.id,
      signedToken: entity.signedToken,
      amount: entity.amount,
      currency: entity.currency,
      bookingId: entity.bookingId,
      tripId: entity.tripId,
      tokenId: entity.tokenId,
      syncStatus: entity.syncStatus.storageValue,
      conflictCode: entity.conflictCode,
      conflictMessage: entity.conflictMessage,
      idempotencyKey: entity.idempotencyKey,
      recordedAt: entity.recordedAt,
      isInbound: entity.isInbound,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'signedToken': signedToken,
      'amount': amount,
      'currency': currency,
      'bookingId': bookingId,
      'tripId': tripId,
      'tokenId': tokenId,
      'syncStatus': syncStatus,
      'conflictCode': conflictCode,
      'conflictMessage': conflictMessage,
      'idempotencyKey': idempotencyKey,
      'recordedAt': recordedAt.toUtc().toIso8601String(),
      'isInbound': isInbound,
    };
  }

  PendingNfcPayment toEntity() {
    return PendingNfcPayment(
      id: id,
      signedToken: signedToken,
      amount: amount,
      currency: currency,
      bookingId: bookingId,
      tripId: tripId,
      tokenId: tokenId,
      syncStatus: NfcSyncStatus.fromStorage(syncStatus),
      conflictCode: conflictCode,
      conflictMessage: conflictMessage,
      idempotencyKey: idempotencyKey,
      recordedAt: recordedAt,
      isInbound: isInbound,
    );
  }
}
