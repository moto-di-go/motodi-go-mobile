part of 'deposit_cubit.dart';

enum DepositFlowStatus { form, submitting, tracking }

class DepositState extends Equatable {
  final DepositFlowStatus status;
  final PaymentProvider? provider;
  final String amountText;
  final double? amount;
  final String phoneText;
  final String? idempotencyKey;
  final WalletDeposit? deposit;
  final bool isRefreshing;
  final String? errorMessage;

  const DepositState({
    this.status = DepositFlowStatus.form,
    this.provider,
    this.amountText = '',
    this.amount,
    this.phoneText = '+237',
    this.idempotencyKey,
    this.deposit,
    this.isRefreshing = false,
    this.errorMessage,
  });

  bool get canSubmit =>
      provider != null &&
      amount != null &&
      amount! >= 1 &&
      phoneText.trim().isNotEmpty &&
      status != DepositFlowStatus.submitting;

  DepositState copyWith({
    DepositFlowStatus? status,
    PaymentProvider? provider,
    String? amountText,
    double? amount,
    String? phoneText,
    String? idempotencyKey,
    WalletDeposit? deposit,
    bool? isRefreshing,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DepositState(
      status: status ?? this.status,
      provider: provider ?? this.provider,
      amountText: amountText ?? this.amountText,
      amount: amount ?? this.amount,
      phoneText: phoneText ?? this.phoneText,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      deposit: deposit ?? this.deposit,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    provider,
    amountText,
    amount,
    phoneText,
    idempotencyKey,
    deposit,
    isRefreshing,
    errorMessage,
  ];
}
