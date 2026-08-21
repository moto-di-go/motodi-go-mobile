import 'package:fpdart/fpdart.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/features/wallet/domain/entities/wallet.dart';

abstract class WalletRepository {
  Future<Either<Failure, WalletAccount>> getWallet();

  Future<Either<Failure, LedgerPage>> getLedger({int page = 0, int size = 20});

  Future<Either<Failure, WalletDeposit>> createDeposit({
    required PaymentProvider provider,
    required double amount,
    required String phoneNumber,
    required String idempotencyKey,
  });

  Future<Either<Failure, WalletDeposit>> getDeposit(String depositId);

  Future<Either<Failure, RidePayment>> payBooking({
    required String bookingId,
    required String idempotencyKey,
  });
}
