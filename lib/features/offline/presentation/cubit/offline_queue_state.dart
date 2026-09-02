part of 'offline_queue_cubit.dart';

enum OfflineQueueStatus { initial, loading, success }

class OfflineQueueState extends Equatable {
  final OfflineQueueStatus status;
  final List<OfflineOperation> operations;

  const OfflineQueueState({
    this.status = OfflineQueueStatus.initial,
    this.operations = const [],
  });

  OfflineQueueState copyWith({
    OfflineQueueStatus? status,
    List<OfflineOperation>? operations,
  }) {
    return OfflineQueueState(
      status: status ?? this.status,
      operations: operations ?? this.operations,
    );
  }

  @override
  List<Object?> get props => [status, operations];
}
