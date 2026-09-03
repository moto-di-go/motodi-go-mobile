import 'package:chopper/chopper.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/auth/data/models/api_error_model.dart';
import 'package:motodi_go_mobile/features/wallet/data/models/wallet_models.dart';

abstract class WalletRemoteDataSource {
  Future<WalletAccountModel> getWallet();

  Future<LedgerPageModel> getLedger({int page = 0, int size = 20});

  Future<WalletDepositModel> createDeposit({
    required String provider,
    required double amount,
    required String phoneNumber,
    required String idempotencyKey,
  });

  Future<WalletDepositModel> getDeposit(String depositId);

  Future<RidePaymentModel> payBooking({required String bookingId, required String idempotencyKey});
}

@LazySingleton(as: WalletRemoteDataSource)
class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final ChopperClient _client;

  WalletRemoteDataSourceImpl(this._client);

  @override
  Future<WalletAccountModel> getWallet() async {
    final response = await _client.get<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/wallet'),
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return WalletAccountModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<LedgerPageModel> getLedger({int page = 0, int size = 20}) async {
    final response = await _client.get<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/wallet/ledger'),
      parameters: {'page': '$page', 'size': '$size'},
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return LedgerPageModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<WalletDepositModel> createDeposit({
    required String provider,
    required double amount,
    required String phoneNumber,
    required String idempotencyKey,
  }) async {
    final response = await _client.post<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/wallet/deposits'),
      body: {'amount': amount, 'currency': 'XAF', 'provider': provider, 'phoneNumber': phoneNumber},
      headers: {'Idempotency-Key': idempotencyKey},
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return WalletDepositModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<WalletDepositModel> getDeposit(String depositId) async {
    final response = await _client.get<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/wallet/deposits/$depositId'),
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return WalletDepositModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<RidePaymentModel> payBooking({
    required String bookingId,
    required String idempotencyKey,
  }) async {
    final response = await _client.post<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/bookings/$bookingId/pay'),
      headers: {'Idempotency-Key': idempotencyKey},
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return RidePaymentModel.fromJson(response.body ?? <String, dynamic>{});
  }
}
