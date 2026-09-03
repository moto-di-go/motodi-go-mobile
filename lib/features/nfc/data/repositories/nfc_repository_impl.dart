import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/core/network/network_info.dart';
import 'package:motodi_go_mobile/features/auth/data/models/api_error_model.dart';
import 'package:motodi_go_mobile/features/nfc/data/datasources/nfc_local_datasource.dart';
import 'package:motodi_go_mobile/features/nfc/data/datasources/nfc_remote_datasource.dart';
import 'package:motodi_go_mobile/features/nfc/data/services/nfc_hardware_service.dart';
import 'package:motodi_go_mobile/features/nfc/domain/entities/nfc_entities.dart';
import 'package:motodi_go_mobile/features/nfc/domain/repositories/nfc_repository.dart';

@LazySingleton(as: NfcRepository)
class NfcRepositoryImpl implements NfcRepository {
  final NfcRemoteDataSource _remote;
  final NfcLocalDataSource _local;
  final NfcHardwareService _hardware;
  final NetworkInfo _networkInfo;

  NfcRepositoryImpl(this._remote, this._local, this._hardware, this._networkInfo);

  @override
  Future<Either<Failure, NfcEligibility>> getEligibility() {
    return _guard(() async {
      final model = await _remote.getEligibility();
      final nfcOk = await _hardware.isNfcAvailable();
      return model.toEntity(
        deviceNfcSupported: nfcOk,
        forceQrOnly: _hardware.forceQrOnly,
      );
    });
  }

  @override
  Future<Either<Failure, NfcPaymentToken>> issueToken({
    required double amount,
    required String currency,
    String? bookingId,
    String? tripId,
    String? receiverWalletId,
    required String idempotencyKey,
  }) {
    return _guard(() async {
      final model = await _remote.issueToken(
        amount: amount,
        currency: currency,
        bookingId: bookingId,
        tripId: tripId,
        receiverWalletId: receiverWalletId,
        idempotencyKey: idempotencyKey,
      );
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, NfcPaymentToken>> getToken(String tokenId) {
    return _guard(() async {
      final model = await _remote.getToken(tokenId);
      return model.toEntity();
    });
  }

  @override
  Future<List<PendingNfcPayment>> listPending() => _local.listPending();

  @override
  Future<void> savePending(PendingNfcPayment payment) => _local.savePending(payment);

  @override
  Future<void> updatePending(PendingNfcPayment payment) => _local.updatePending(payment);

  @override
  Future<void> removePending(String id) => _local.removePending(id);

  @override
  Future<Either<Failure, NfcSyncBatchResult>> syncPending(List<PendingNfcPayment> payments) {
    return _guard(() async {
      final toSync = payments
          .where(
            (p) =>
                p.syncStatus == NfcSyncStatus.localStored ||
                p.syncStatus == NfcSyncStatus.pendingSync ||
                p.syncStatus == NfcSyncStatus.conflict,
          )
          .toList();
      if (toSync.isEmpty) {
        return const NfcSyncBatchResult(batchId: '', status: 'EMPTY', results: []);
      }

      for (final p in toSync) {
        await _local.updatePending(p.copyWith(syncStatus: NfcSyncStatus.pendingSync));
      }

      final operations = toSync
          .map(
            (p) => {
              'type': 'NFC_PAYMENT',
              'idempotencyKey': p.idempotencyKey,
              'payload': {
                'signedToken': p.signedToken,
                if (p.bookingId != null) 'bookingId': p.bookingId,
                if (p.tripId != null) 'tripId': p.tripId,
                'amount': p.amount,
                'currency': p.currency,
              },
              'queuedAt': p.recordedAt.toUtc().toIso8601String(),
            },
          )
          .toList();

      final model = await _remote.syncOffline(operations: operations);
      final result = model.toEntity();

      for (final item in result.results) {
        PendingNfcPayment? pending;
        for (final p in toSync) {
          if (p.idempotencyKey == item.idempotencyKey) {
            pending = p;
            break;
          }
        }
        if (pending == null) continue;
        if (item.isSynced) {
          await _local.updatePending(pending.copyWith(syncStatus: NfcSyncStatus.synced));
        } else if (item.isConflict) {
          await _local.updatePending(
            pending.copyWith(
              syncStatus: NfcSyncStatus.conflict,
              conflictCode: item.conflictCode,
              conflictMessage: item.message,
            ),
          );
        } else if (item.isFailed) {
          await _local.updatePending(
            pending.copyWith(
              syncStatus: NfcSyncStatus.rejected,
              conflictMessage: item.message,
            ),
          );
        }
      }

      return result;
    });
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    if (!await _networkInfo.isConnected) {
      return left(const NetworkFailure('Pas de connexion internet.', code: 'NETWORK_OFFLINE'));
    }
    try {
      return right(await action());
    } catch (error) {
      return left(_failureFromException(error));
    }
  }

  Failure _failureFromException(Object error) {
    if (error is ApiException) {
      return switch (error.code) {
        'SESSION_EXPIRED' => AuthFailure(error.message, code: error.code),
        'NFC_NOT_ALLOWED' ||
        'WALLET_FROZEN' ||
        'WALLET_CLOSED' ||
        'INSUFFICIENT_BALANCE' ||
        'VALIDATION_ERROR' ||
        'TOKEN_EXPIRED' ||
        'TOKEN_CONSUMED' => ValidationFailure(error.message, code: error.code),
        _ => ServerFailure(error.message, code: error.code),
      };
    }
    return ServerFailure(error.toString());
  }
}
