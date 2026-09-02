part of 'nfc_sync_cubit.dart';

enum NfcSyncStatusView { initial, syncing, success, conflict, failure }

class NfcSyncState extends Equatable {
  final NfcSyncStatusView status;
  final NfcSyncBatchResult? batch;
  final List<NfcSyncItemResult> conflicts;
  final List<PendingNfcPayment> pendingAfter;
  final String? errorMessage;

  const NfcSyncState({
    this.status = NfcSyncStatusView.initial,
    this.batch,
    this.conflicts = const [],
    this.pendingAfter = const [],
    this.errorMessage,
  });

  NfcSyncState copyWith({
    NfcSyncStatusView? status,
    NfcSyncBatchResult? batch,
    List<NfcSyncItemResult>? conflicts,
    List<PendingNfcPayment>? pendingAfter,
    String? errorMessage,
  }) {
    return NfcSyncState(
      status: status ?? this.status,
      batch: batch ?? this.batch,
      conflicts: conflicts ?? this.conflicts,
      pendingAfter: pendingAfter ?? this.pendingAfter,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, batch, conflicts, pendingAfter, errorMessage];
}
