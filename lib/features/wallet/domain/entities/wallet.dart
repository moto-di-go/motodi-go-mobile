import 'package:equatable/equatable.dart';

enum WalletStatus {
  active,
  frozen,
  closed,
  unknown;

  static WalletStatus fromApi(String? value) {
    return switch (value?.toUpperCase()) {
      'ACTIVE' => WalletStatus.active,
      'FROZEN' => WalletStatus.frozen,
      'CLOSED' => WalletStatus.closed,
      _ => WalletStatus.unknown,
    };
  }

  String get labelFr => switch (this) {
    WalletStatus.active => 'Actif',
    WalletStatus.frozen => 'Gelé',
    WalletStatus.closed => 'Fermé',
    WalletStatus.unknown => 'Inconnu',
  };
}

enum LedgerEntryType {
  credit,
  debit,
  reversal,
  hold,
  release,
  unknown;

  static LedgerEntryType fromApi(String? value) {
    return switch (value?.toUpperCase()) {
      'CREDIT' => LedgerEntryType.credit,
      'DEBIT' => LedgerEntryType.debit,
      'REVERSAL' => LedgerEntryType.reversal,
      'HOLD' => LedgerEntryType.hold,
      'RELEASE' => LedgerEntryType.release,
      _ => LedgerEntryType.unknown,
    };
  }

  bool get isCredit => this == LedgerEntryType.credit || this == LedgerEntryType.release;

  String get labelFr => switch (this) {
    LedgerEntryType.credit => 'Crédit',
    LedgerEntryType.debit => 'Débit',
    LedgerEntryType.reversal => 'Contrepassation',
    LedgerEntryType.hold => 'Réservation',
    LedgerEntryType.release => 'Libération',
    LedgerEntryType.unknown => 'Mouvement',
  };
}

enum PaymentProvider {
  mtnMomo,
  orangeMoney,
  aggregator,
  wallet,
  nfc,
  unknown;

  static PaymentProvider fromApi(String? value) {
    return switch (value?.toUpperCase()) {
      'MTN_MOMO' => PaymentProvider.mtnMomo,
      'ORANGE_MONEY' => PaymentProvider.orangeMoney,
      'AGGREGATOR' => PaymentProvider.aggregator,
      'WALLET' => PaymentProvider.wallet,
      'NFC' => PaymentProvider.nfc,
      _ => PaymentProvider.unknown,
    };
  }

  String get apiValue => switch (this) {
    PaymentProvider.mtnMomo => 'MTN_MOMO',
    PaymentProvider.orangeMoney => 'ORANGE_MONEY',
    PaymentProvider.aggregator => 'AGGREGATOR',
    PaymentProvider.wallet => 'WALLET',
    PaymentProvider.nfc => 'NFC',
    PaymentProvider.unknown => 'UNKNOWN',
  };

  String get labelFr => switch (this) {
    PaymentProvider.mtnMomo => 'MTN MoMo',
    PaymentProvider.orangeMoney => 'Orange Money',
    PaymentProvider.aggregator => 'Agrégateur',
    PaymentProvider.wallet => 'Wallet',
    PaymentProvider.nfc => 'NFC',
    PaymentProvider.unknown => 'Fournisseur',
  };

  static const List<PaymentProvider> depositProviders = [
    PaymentProvider.mtnMomo,
    PaymentProvider.orangeMoney,
    PaymentProvider.aggregator,
  ];
}

enum PaymentStatus {
  initiated,
  pendingCallback,
  confirmed,
  failed,
  expired,
  refunded,
  unknown;

  static PaymentStatus fromApi(String? value) {
    return switch (value?.toUpperCase()) {
      'INITIATED' => PaymentStatus.initiated,
      'PENDING_CALLBACK' => PaymentStatus.pendingCallback,
      'CONFIRMED' => PaymentStatus.confirmed,
      'FAILED' => PaymentStatus.failed,
      'EXPIRED' => PaymentStatus.expired,
      'REFUNDED' => PaymentStatus.refunded,
      _ => PaymentStatus.unknown,
    };
  }

  bool get isTerminal =>
      this == PaymentStatus.confirmed ||
      this == PaymentStatus.failed ||
      this == PaymentStatus.expired ||
      this == PaymentStatus.refunded;

  bool get isPending => this == PaymentStatus.initiated || this == PaymentStatus.pendingCallback;

  String get labelFr => switch (this) {
    PaymentStatus.initiated => 'Initié',
    PaymentStatus.pendingCallback => 'En attente',
    PaymentStatus.confirmed => 'Confirmé',
    PaymentStatus.failed => 'Échoué',
    PaymentStatus.expired => 'Expiré',
    PaymentStatus.refunded => 'Remboursé',
    PaymentStatus.unknown => 'Inconnu',
  };
}

class WalletAccount extends Equatable {
  final String id;
  final String currency;
  final double currentBalance;
  final WalletStatus status;
  final DateTime? createdAt;
  final DateTime? lastUpdatedAt;

  const WalletAccount({
    required this.id,
    required this.currency,
    required this.currentBalance,
    required this.status,
    this.createdAt,
    this.lastUpdatedAt,
  });

  bool get isFrozen => status == WalletStatus.frozen;
  bool get isClosed => status == WalletStatus.closed;
  bool get canTransact => status == WalletStatus.active;

  WalletAccount copyWith({double? currentBalance, WalletStatus? status, DateTime? lastUpdatedAt}) {
    return WalletAccount(
      id: id,
      currency: currency,
      currentBalance: currentBalance ?? this.currentBalance,
      status: status ?? this.status,
      createdAt: createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  @override
  List<Object?> get props => [id, currency, currentBalance, status, createdAt, lastUpdatedAt];
}

class LedgerEntry extends Equatable {
  final String id;
  final LedgerEntryType type;
  final double amount;
  final String currency;
  final String? reference;
  final DateTime bookedAt;

  const LedgerEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    this.reference,
    required this.bookedAt,
  });

  @override
  List<Object?> get props => [id, type, amount, currency, reference, bookedAt];
}

class LedgerPage extends Equatable {
  final List<LedgerEntry> entries;
  final int page;
  final int size;
  final bool hasMore;

  const LedgerPage({
    required this.entries,
    required this.page,
    required this.size,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [entries, page, size, hasMore];
}

class WalletDeposit extends Equatable {
  final String id;
  final PaymentStatus status;
  final double amount;
  final String currency;
  final PaymentProvider? provider;
  final String? payerPhone;
  final String? externalReference;
  final String? failureReason;
  final DateTime? initiatedAt;
  final DateTime? confirmedAt;

  const WalletDeposit({
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

  @override
  List<Object?> get props => [
    id,
    status,
    amount,
    currency,
    provider,
    payerPhone,
    externalReference,
    failureReason,
    initiatedAt,
    confirmedAt,
  ];
}

class RidePayment extends Equatable {
  final String id;
  final String bookingId;
  final PaymentStatus status;
  final double amount;
  final double? platformFee;
  final double? transporterAmount;
  final String currency;
  final PaymentProvider? provider;
  final DateTime? initiatedAt;
  final DateTime? confirmedAt;
  final String? receiptId;
  final String? receiptNumber;
  final String? receiptPdfUrl;

  const RidePayment({
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

  WalletReceipt? get receipt {
    if (receiptId == null && receiptNumber == null) return null;
    return WalletReceipt(
      id: receiptId ?? id,
      receiptNumber: receiptNumber ?? id,
      amount: amount,
      currency: currency,
      status: status,
      issuedAt: confirmedAt ?? initiatedAt ?? DateTime.now(),
      bookingId: bookingId,
      pdfUrl: receiptPdfUrl,
    );
  }

  @override
  List<Object?> get props => [
    id,
    bookingId,
    status,
    amount,
    platformFee,
    transporterAmount,
    currency,
    provider,
    initiatedAt,
    confirmedAt,
    receiptId,
    receiptNumber,
    receiptPdfUrl,
  ];
}

class WalletReceipt extends Equatable {
  final String id;
  final String receiptNumber;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final DateTime issuedAt;
  final String? bookingId;
  final String? pdfUrl;

  const WalletReceipt({
    required this.id,
    required this.receiptNumber,
    required this.amount,
    required this.currency,
    required this.status,
    required this.issuedAt,
    this.bookingId,
    this.pdfUrl,
  });

  @override
  List<Object?> get props => [
    id,
    receiptNumber,
    amount,
    currency,
    status,
    issuedAt,
    bookingId,
    pdfUrl,
  ];
}
