import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/core/network/network_info.dart';
import 'package:motodi_go_mobile/features/auth/data/models/api_error_model.dart';
import 'package:motodi_go_mobile/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:motodi_go_mobile/features/wallet/domain/entities/wallet.dart';
import 'package:motodi_go_mobile/features/wallet/domain/repositories/wallet_repository.dart';

@LazySingleton(as: WalletRepository)
class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  WalletRepositoryImpl(this._remoteDataSource, this._networkInfo);

  @override
  Future<Either<Failure, WalletAccount>> getWallet() {
    return _guard(() async {
      final model = await _remoteDataSource.getWallet();
      return model.toEntity(lastUpdatedAt: DateTime.now());
    });
  }

  @override
  Future<Either<Failure, LedgerPage>> getLedger({int page = 0, int size = 20}) {
    return _guard(() async {
      final model = await _remoteDataSource.getLedger(page: page, size: size);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, WalletDeposit>> createDeposit({
    required PaymentProvider provider,
    required double amount,
    required String phoneNumber,
    required String idempotencyKey,
  }) {
    return _guard(() async {
      final model = await _remoteDataSource.createDeposit(
        provider: provider.apiValue,
        amount: amount,
        phoneNumber: phoneNumber,
        idempotencyKey: idempotencyKey,
      );
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, WalletDeposit>> getDeposit(String depositId) {
    return _guard(() async {
      final model = await _remoteDataSource.getDeposit(depositId);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, RidePayment>> payBooking({
    required String bookingId,
    required String idempotencyKey,
  }) {
    return _guard(() async {
      final model = await _remoteDataSource.payBooking(
        bookingId: bookingId,
        idempotencyKey: idempotencyKey,
      );
      return model.toEntity();
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
        'WALLET_FROZEN' ||
        'WALLET_CLOSED' ||
        'INSUFFICIENT_BALANCE' ||
        'INVALID_PHONE' ||
        'VALIDATION_ERROR' => ValidationFailure(error.message, code: error.code),
        'DEPOSIT_NOT_FOUND' ||
        'BOOKING_NOT_FOUND' ||
        'PAYMENT_NOT_FOUND' => ValidationFailure(error.message, code: error.code),
        _ => ServerFailure(error.message, code: error.code),
      };
    }
    return ServerFailure(error.toString());
  }
}
