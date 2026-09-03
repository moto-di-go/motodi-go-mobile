part of 'nfc_pay_cubit.dart';

enum NfcPayStatus { initial, checking, ready, notEligible, issuing, issued, failure }

class NfcPayState extends Equatable {
  final NfcPayStatus status;
  final NfcEligibility? eligibility;
  final NfcPaymentToken? token;
  final double? amount;
  final String currency;
  final String? bookingId;
  final String? tripId;
  final String? errorMessage;

  const NfcPayState({
    this.status = NfcPayStatus.initial,
    this.eligibility,
    this.token,
    this.amount,
    this.currency = 'XAF',
    this.bookingId,
    this.tripId,
    this.errorMessage,
  });

  NfcPayState copyWith({
    NfcPayStatus? status,
    NfcEligibility? eligibility,
    NfcPaymentToken? token,
    double? amount,
    String? currency,
    String? bookingId,
    String? tripId,
    String? errorMessage,
  }) {
    return NfcPayState(
      status: status ?? this.status,
      eligibility: eligibility ?? this.eligibility,
      token: token ?? this.token,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      bookingId: bookingId ?? this.bookingId,
      tripId: tripId ?? this.tripId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    eligibility,
    token,
    amount,
    currency,
    bookingId,
    tripId,
    errorMessage,
  ];
}
