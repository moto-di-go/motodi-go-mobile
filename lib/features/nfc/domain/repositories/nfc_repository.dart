import 'package:fpdart/fpdart.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/features/nfc/domain/entities/nfc_entities.dart';

abstract class NfcRepository {
  Future<Either<Failure, NfcEligibility>> getEligibility();

  Future<Either<Failure, NfcPaymentToken>> issueToken({
    required double amount,
    required String currency,
    String? bookingId,
    String? tripId,
    String? receiverWalletId,
    required String idempotencyKey,
  });

  Future<Either<Failure, NfcPaymentToken>> getToken(String tokenId);

  Future<List<PendingNfcPayment>> listPending();

  Future<void> savePending(PendingNfcPayment payment);

  Future<void> updatePending(PendingNfcPayment payment);

  Future<void> removePending(String id);

  Future<Either<Failure, NfcSyncBatchResult>> syncPending(List<PendingNfcPayment> payments);
}
