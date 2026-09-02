part of 'nfc_pending_cubit.dart';

enum NfcPendingStatus { initial, loading, success }

class NfcPendingState extends Equatable {
  final NfcPendingStatus status;
  final List<PendingNfcPayment> items;

  const NfcPendingState({
    this.status = NfcPendingStatus.initial,
    this.items = const [],
  });

  List<PendingNfcPayment> get actionable => items
      .where(
        (e) =>
            e.syncStatus == NfcSyncStatus.localStored ||
            e.syncStatus == NfcSyncStatus.pendingSync ||
            e.syncStatus == NfcSyncStatus.conflict,
      )
      .toList();

  NfcPendingState copyWith({
    NfcPendingStatus? status,
    List<PendingNfcPayment>? items,
  }) {
    return NfcPendingState(
      status: status ?? this.status,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [status, items];
}
