part of 'nfc_emit_cubit.dart';

enum NfcEmitStatus { initial, loading, ready, emitted, expired, failure }

class NfcEmitState extends Equatable {
  final NfcEmitStatus status;
  final NfcPaymentToken? token;
  final Duration remaining;
  final bool useQr;
  final bool nfcAvailable;
  final String? statusMessage;
  final String? errorMessage;

  const NfcEmitState({
    this.status = NfcEmitStatus.initial,
    this.token,
    this.remaining = Duration.zero,
    this.useQr = true,
    this.nfcAvailable = false,
    this.statusMessage,
    this.errorMessage,
  });

  NfcEmitState copyWith({
    NfcEmitStatus? status,
    NfcPaymentToken? token,
    Duration? remaining,
    bool? useQr,
    bool? nfcAvailable,
    String? statusMessage,
    String? errorMessage,
  }) {
    return NfcEmitState(
      status: status ?? this.status,
      token: token ?? this.token,
      remaining: remaining ?? this.remaining,
      useQr: useQr ?? this.useQr,
      nfcAvailable: nfcAvailable ?? this.nfcAvailable,
      statusMessage: statusMessage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    token,
    remaining,
    useQr,
    nfcAvailable,
    statusMessage,
    errorMessage,
  ];
}
