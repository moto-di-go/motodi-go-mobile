part of 'connectivity_cubit.dart';

class ConnectivityState extends Equatable {
  final ConnectivityStatus status;
  final DateTime? lastSyncAt;
  final int pendingCount;
  final bool isSyncing;
  final OfflineSyncBatchResult? lastBatch;

  const ConnectivityState({
    this.status = ConnectivityStatus.online,
    this.lastSyncAt,
    this.pendingCount = 0,
    this.isSyncing = false,
    this.lastBatch,
  });

  bool get isOffline => status == ConnectivityStatus.offline;
  bool get isWeak => status == ConnectivityStatus.weakNetwork;
  bool get showBanner => isOffline || isWeak || pendingCount > 0 || isSyncing;

  ConnectivityState copyWith({
    ConnectivityStatus? status,
    DateTime? lastSyncAt,
    int? pendingCount,
    bool? isSyncing,
    OfflineSyncBatchResult? lastBatch,
  }) {
    return ConnectivityState(
      status: status ?? this.status,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      pendingCount: pendingCount ?? this.pendingCount,
      isSyncing: isSyncing ?? this.isSyncing,
      lastBatch: lastBatch ?? this.lastBatch,
    );
  }

  @override
  List<Object?> get props => [status, lastSyncAt, pendingCount, isSyncing, lastBatch];
}
