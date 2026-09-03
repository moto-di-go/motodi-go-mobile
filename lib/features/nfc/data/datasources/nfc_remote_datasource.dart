import 'package:chopper/chopper.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/auth/data/models/api_error_model.dart';
import 'package:motodi_go_mobile/features/nfc/data/models/nfc_models.dart';

abstract class NfcRemoteDataSource {
  Future<NfcEligibilityModel> getEligibility();

  Future<NfcTokenModel> issueToken({
    required double amount,
    required String currency,
    String? bookingId,
    String? tripId,
    String? receiverWalletId,
    required String idempotencyKey,
  });

  Future<NfcTokenModel> getToken(String tokenId);

  Future<NfcSyncBatchModel> syncOffline({
    required List<Map<String, dynamic>> operations,
  });
}

@LazySingleton(as: NfcRemoteDataSource)
class NfcRemoteDataSourceImpl implements NfcRemoteDataSource {
  final ChopperClient _client;

  NfcRemoteDataSourceImpl(this._client);

  @override
  Future<NfcEligibilityModel> getEligibility() async {
    final response = await _client.get<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/nfc/eligibility'),
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return NfcEligibilityModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<NfcTokenModel> issueToken({
    required double amount,
    required String currency,
    String? bookingId,
    String? tripId,
    String? receiverWalletId,
    required String idempotencyKey,
  }) async {
    final body = <String, dynamic>{
      'amount': amount,
      'currency': currency,
      if (bookingId != null && bookingId.isNotEmpty) 'bookingId': bookingId,
      if (tripId != null && tripId.isNotEmpty) 'tripId': tripId,
      if (receiverWalletId != null && receiverWalletId.isNotEmpty)
        'receiverWalletId': receiverWalletId,
    };
    final response = await _client.post<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/nfc/tokens'),
      body: body,
      headers: {'Idempotency-Key': idempotencyKey},
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return NfcTokenModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<NfcTokenModel> getToken(String tokenId) async {
    final response = await _client.get<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/nfc/tokens/$tokenId'),
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return NfcTokenModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<NfcSyncBatchModel> syncOffline({
    required List<Map<String, dynamic>> operations,
  }) async {
    final response = await _client.post<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/offline/sync'),
      body: {'operations': operations},
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return NfcSyncBatchModel.fromJson(response.body ?? <String, dynamic>{});
  }
}
