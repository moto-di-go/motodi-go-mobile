part of 'offline_maps_cubit.dart';

enum OfflineMapsStatus { initial, loading, success, failure }

class OfflineMapsState extends Equatable {
  final OfflineMapsStatus status;
  final List<OfflineMapArea> areas;
  final OfflineStorageUsage? usage;
  final String? downloadingId;
  final double? downloadProgress;
  final String? errorMessage;
  final String? successMessage;

  const OfflineMapsState({
    this.status = OfflineMapsStatus.initial,
    this.areas = const [],
    this.usage,
    this.downloadingId,
    this.downloadProgress,
    this.errorMessage,
    this.successMessage,
  });

  OfflineMapsState copyWith({
    OfflineMapsStatus? status,
    List<OfflineMapArea>? areas,
    OfflineStorageUsage? usage,
    Object? downloadingId = _unset,
    Object? downloadProgress = _unset,
    Object? errorMessage = _unset,
    Object? successMessage = _unset,
  }) {
    return OfflineMapsState(
      status: status ?? this.status,
      areas: areas ?? this.areas,
      usage: usage ?? this.usage,
      downloadingId: identical(downloadingId, _unset)
          ? this.downloadingId
          : downloadingId as String?,
      downloadProgress: identical(downloadProgress, _unset)
          ? this.downloadProgress
          : (downloadProgress == null ? null : (downloadProgress as num).toDouble()),
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      successMessage: identical(successMessage, _unset)
          ? this.successMessage
          : successMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    areas,
    usage,
    downloadingId,
    downloadProgress,
    errorMessage,
    successMessage,
  ];
}

const Object _unset = Object();
