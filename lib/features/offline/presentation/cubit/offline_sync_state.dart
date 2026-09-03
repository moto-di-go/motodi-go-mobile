part of 'offline_sync_cubit.dart';

enum OfflineSyncViewStatus { idle, syncing, success, failure, conflict }

class OfflineSyncViewState extends Equatable {
  final OfflineSyncViewStatus status;
  final OfflineSyncBatchResult? batch;
  final List<OfflineSyncItemResult> conflicts;
  final double progress;
  final String? errorMessage;

  const OfflineSyncViewState({
    this.status = OfflineSyncViewStatus.idle,
    this.batch,
    this.conflicts = const [],
    this.progress = 0,
    this.errorMessage,
  });

  OfflineSyncViewState copyWith({
    OfflineSyncViewStatus? status,
    OfflineSyncBatchResult? batch,
    List<OfflineSyncItemResult>? conflicts,
    double? progress,
    String? errorMessage,
  }) {
    return OfflineSyncViewState(
      status: status ?? this.status,
      batch: batch ?? this.batch,
      conflicts: conflicts ?? this.conflicts,
      progress: progress ?? this.progress,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, batch, conflicts, progress, errorMessage];
}
