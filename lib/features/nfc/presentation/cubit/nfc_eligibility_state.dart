part of 'nfc_eligibility_cubit.dart';

enum NfcEligibilityStatus { initial, loading, success, failure }

class NfcEligibilityState extends Equatable {
  final NfcEligibilityStatus status;
  final NfcEligibility? eligibility;
  final String? errorMessage;

  const NfcEligibilityState({
    this.status = NfcEligibilityStatus.initial,
    this.eligibility,
    this.errorMessage,
  });

  bool get isLoading =>
      status == NfcEligibilityStatus.loading || status == NfcEligibilityStatus.initial;

  NfcEligibilityState copyWith({
    NfcEligibilityStatus? status,
    NfcEligibility? eligibility,
    String? errorMessage,
  }) {
    return NfcEligibilityState(
      status: status ?? this.status,
      eligibility: eligibility ?? this.eligibility,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, eligibility, errorMessage];
}
