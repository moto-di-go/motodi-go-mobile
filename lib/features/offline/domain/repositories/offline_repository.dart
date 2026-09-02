import 'package:fpdart/fpdart.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/features/offline/domain/entities/offline_entities.dart';

abstract class OfflineRepository {
  Future<List<OfflineOperation>> listLocalOperations({bool pendingOnly = false});

  Future<OfflineOperation> enqueue({
    required OfflineOperationType type,
    required Map<String, dynamic> payload,
    String? idempotencyKey,
  });

  Future<Either<Failure, List<OfflineMapArea>>> getMapAreas();

  Future<Either<Failure, OfflineMapArea>> downloadMapArea(
    OfflineMapArea area, {
    void Function(double progress)? onProgress,
  });

  Future<void> deleteMapArea(String id);

  Future<Either<Failure, OfflineSyncBatchResult>> syncPending();

  Future<Either<Failure, List<OfflineOperation>>> listRemoteOperations({
    String? status,
    int page = 0,
    int size = 20,
  });

  Future<OfflineCacheSettings> getSettings();

  Future<void> saveSettings(OfflineCacheSettings settings);

  Future<OfflineStorageUsage> storageUsage();

  DateTime? get lastSyncAt;

  Future<void> clearCaches({bool bookings = true, bool receipts = true, bool maps = false});
}
