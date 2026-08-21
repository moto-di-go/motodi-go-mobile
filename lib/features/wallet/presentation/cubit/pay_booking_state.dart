part of 'pay_booking_cubit.dart';

enum PayBookingStatus { initial, loading, ready, paying, success, failure }

class PayBookingState extends Equatable {
  final PayBookingStatus status;
  final String? bookingId;
  final double? expectedAmount;
  final WalletAccount? wallet;
  final RidePayment? payment;
  final String? idempotencyKey;
  final String? errorMessage;

  const PayBookingState({
    this.status = PayBookingStatus.initial,
    this.bookingId,
    this.expectedAmount,
    this.wallet,
    this.payment,
    this.idempotencyKey,
    this.errorMessage,
  });

  bool get hasInsufficientBalance {
    final amount = expectedAmount;
    final balance = wallet?.currentBalance;
    if (amount == null || balance == null) return false;
    return balance < amount;
  }

  bool get canPay =>
      status == PayBookingStatus.ready && wallet?.canTransact == true && !hasInsufficientBalance;

  PayBookingState copyWith({
    PayBookingStatus? status,
    String? bookingId,
    double? expectedAmount,
    WalletAccount? wallet,
    RidePayment? payment,
    String? idempotencyKey,
    String? errorMessage,
    bool clearError = false,
    bool clearPayment = false,
  }) {
    return PayBookingState(
      status: status ?? this.status,
      bookingId: bookingId ?? this.bookingId,
      expectedAmount: expectedAmount ?? this.expectedAmount,
      wallet: wallet ?? this.wallet,
      payment: clearPayment ? null : (payment ?? this.payment),
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    bookingId,
    expectedAmount,
    wallet,
    payment,
    idempotencyKey,
    errorMessage,
  ];
}
