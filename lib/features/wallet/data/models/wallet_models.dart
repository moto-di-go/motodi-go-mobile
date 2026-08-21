import 'package:motodi_go_mobile/features/wallet/domain/entities/wallet.dart';

double _asDouble(Object? value, [double fallback = 0]) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? fallback;
}

int _asInt(Object? value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}

DateTime? _asDate(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value)?.toLocal();
}

class WalletAccountModel {
  final String id;
  final String currency;
  final double currentBalance;
  final String status;
  final DateTime? createdAt;

  const WalletAccountModel({
    required this.id,
    required this.currency,
    required this.currentBalance,
    required this.status,
    this.createdAt,
  });

  factory WalletAccountModel.fromJson(Map<String, dynamic> json) {
    return WalletAccountModel(
      id: json['id']?.toString() ?? '',
      currency: json['currency'] as String? ?? 'XAF',
      currentBalance: _asDouble(json['currentBalance']),
      status: json['status'] as String? ?? 'ACTIVE',
      createdAt: _asDate(json['createdAt']),
    );
  }

  WalletAccount toEntity({DateTime? lastUpdatedAt}) {
    return WalletAccount(
      id: id,
      currency: currency,
      currentBalance: currentBalance,
      status: WalletStatus.fromApi(status),
      createdAt: createdAt,
      lastUpdatedAt: lastUpdatedAt ?? DateTime.now(),
    );
  }
}

class LedgerEntryModel {
  final String id;
  final String type;
  final double amount;
  final String currency;
  final String? reference;
  final DateTime bookedAt;

  const LedgerEntryModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    this.reference,
    required this.bookedAt,
  });

  factory LedgerEntryModel.fromJson(Map<String, dynamic> json) {
    return LedgerEntryModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] as String? ?? '',
      amount: _asDouble(json['amount']),
      currency: json['currency'] as String? ?? 'XAF',
      reference: json['reference']?.toString(),
      bookedAt: _asDate(json['bookedAt']) ?? DateTime.now(),
    );
  }

  LedgerEntry toEntity() {
    return LedgerEntry(
      id: id,
      type: LedgerEntryType.fromApi(type),
      amount: amount,
      currency: currency,
      reference: reference,
      bookedAt: bookedAt,
    );
  }
}

class LedgerPageModel {
  final List<LedgerEntryModel> entries;
  final int page;
  final int size;
  final bool hasMore;

  const LedgerPageModel({
    required this.entries,
    required this.page,
    required this.size,
    required this.hasMore,
  });

  factory LedgerPageModel.fromJson(Map<String, dynamic> json) {
    final raw = json['entries'] as List? ?? const [];
    return LedgerPageModel(
      entries: raw
          .map((item) => LedgerEntryModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      page: _asInt(json['page']),
      size: _asInt(json['size'], 20),
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  LedgerPage toEntity() {
    return LedgerPage(
      entries: entries.map((e) => e.toEntity()).toList(),
      page: page,
      size: size,
      hasMore: hasMore,
    );
  }
}

class WalletDepositModel {
  final String id;
  final String status;
  final double amount;
  final String currency;
  final String? provider;
  final String? payerPhone;
  final String? externalReference;
  final String? failureReason;
  final DateTime? initiatedAt;
  final DateTime? confirmedAt;

  const WalletDepositModel({
    required this.id,
    required this.status,
    required this.amount,
    required this.currency,
    this.provider,
    this.payerPhone,
    this.externalReference,
    this.failureReason,
    this.initiatedAt,
    this.confirmedAt,
  });

  factory WalletDepositModel.fromJson(Map<String, dynamic> json) {
    return WalletDepositModel(
      id: json['id']?.toString() ?? '',
      status: json['status'] as String? ?? '',
      amount: _asDouble(json['amount']),
      currency: json['currency'] as String? ?? 'XAF',
      provider: json['provider'] as String?,
      payerPhone: json['payerPhone'] as String?,
      externalReference: json['externalReference'] as String?,
      failureReason: json['failureReason'] as String?,
      initiatedAt: _asDate(json['initiatedAt']),
      confirmedAt: _asDate(json['confirmedAt']),
    );
  }

  WalletDeposit toEntity() {
    return WalletDeposit(
      id: id,
      status: PaymentStatus.fromApi(status),
      amount: amount,
      currency: currency,
      provider: provider == null ? null : PaymentProvider.fromApi(provider),
      payerPhone: payerPhone,
      externalReference: externalReference,
      failureReason: failureReason,
      initiatedAt: initiatedAt,
      confirmedAt: confirmedAt,
    );
  }
}

class RidePaymentModel {
  final String id;
  final String bookingId;
  final String status;
  final double amount;
  final double? platformFee;
  final double? transporterAmount;
  final String currency;
  final String? provider;
  final DateTime? initiatedAt;
  final DateTime? confirmedAt;
  final String? receiptId;
  final String? receiptNumber;
  final String? receiptPdfUrl;

  const RidePaymentModel({
    required this.id,
    required this.bookingId,
    required this.status,
    required this.amount,
    this.platformFee,
    this.transporterAmount,
    required this.currency,
    this.provider,
    this.initiatedAt,
    this.confirmedAt,
    this.receiptId,
    this.receiptNumber,
    this.receiptPdfUrl,
  });

  factory RidePaymentModel.fromJson(Map<String, dynamic> json) {
    return RidePaymentModel(
      id: json['id']?.toString() ?? '',
      bookingId: json['bookingId']?.toString() ?? '',
      status: json['status'] as String? ?? '',
      amount: _asDouble(json['amount']),
      platformFee: json['platformFee'] == null ? null : _asDouble(json['platformFee']),
      transporterAmount: json['transporterAmount'] == null
          ? null
          : _asDouble(json['transporterAmount']),
      currency: json['currency'] as String? ?? 'XAF',
      provider: json['provider'] as String?,
      initiatedAt: _asDate(json['initiatedAt']),
      confirmedAt: _asDate(json['confirmedAt']),
      receiptId: json['receiptId']?.toString(),
      receiptNumber: json['receiptNumber'] as String?,
      receiptPdfUrl: json['receiptPdfUrl'] as String?,
    );
  }

  RidePayment toEntity() {
    return RidePayment(
      id: id,
      bookingId: bookingId,
      status: PaymentStatus.fromApi(status),
      amount: amount,
      platformFee: platformFee,
      transporterAmount: transporterAmount,
      currency: currency,
      provider: provider == null ? null : PaymentProvider.fromApi(provider),
      initiatedAt: initiatedAt,
      confirmedAt: confirmedAt,
      receiptId: receiptId,
      receiptNumber: receiptNumber,
      receiptPdfUrl: receiptPdfUrl,
    );
  }
}
