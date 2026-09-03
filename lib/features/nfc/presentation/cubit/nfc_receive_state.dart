part of 'nfc_receive_cubit.dart';

enum NfcReceiveStatus { initial, listening, success, failure }

class NfcReceiveState extends Equatable {
  final NfcReceiveStatus status;
  final double? expectedAmount;
  final String currency;
  final bool nfcAvailable;
  final bool forceQr;
  final PendingNfcPayment? pending;
  final String? successMessage;
  final String? hintMessage;
  final String? errorMessage;

  const NfcReceiveState({
    this.status = NfcReceiveStatus.initial,
    this.expectedAmount,
    this.currency = 'XAF',
    this.nfcAvailable = false,
    this.forceQr = true,
    this.pending,
    this.successMessage,
    this.hintMessage,
    this.errorMessage,
  });

  NfcReceiveState copyWith({
    NfcReceiveStatus? status,
    double? expectedAmount,
    String? currency,
    bool? nfcAvailable,
    bool? forceQr,
    PendingNfcPayment? pending,
    String? successMessage,
    String? hintMessage,
    String? errorMessage,
  }) {
    return NfcReceiveState(
      status: status ?? this.status,
      expectedAmount: expectedAmount ?? this.expectedAmount,
      currency: currency ?? this.currency,
      nfcAvailable: nfcAvailable ?? this.nfcAvailable,
      forceQr: forceQr ?? this.forceQr,
      pending: pending ?? this.pending,
      successMessage: successMessage,
      hintMessage: hintMessage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    expectedAmount,
    currency,
    nfcAvailable,
    forceQr,
    pending,
    successMessage,
    hintMessage,
    errorMessage,
  ];
}
