part of 'offline_maps_cubit.dart';

enum OfflineMapsStatus { initial, loading, success, failure }

class OfflineMapsState extends Equatable {
  final OfflineMapsStatus status;
  final List<OfflineMapArea> areas;
  final OfflineStorageUsage? usage;
  final String? downloadingId;
  final double? downloadProgress;
  final String? errorMessage;

  const OfflineMapsState({
    this.status = OfflineMapsStatus.initial,
    this.areas = const [],
    this.usage,
    this.downloadingId,
    this.downloadProgress,
    this.errorMessage,
  });

  OfflineMapsState copyWith({
    OfflineMapsStatus? status,
    List<OfflineMapArea>? areas,
    OfflineStorageUsage? usage,
    String? downloadingId,
    double? downloadProgress,
    String? errorMessage,
  }) {
    return OfflineMapsState(
      status: status ?? this.status,
      areas: areas ?? this.areas,
      usage: usage ?? this.usage,
      downloadingId: downloadingId,
      downloadProgress: downloadProgress,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, areas, usage, downloadingId, downloadProgress, errorMessage];
}
