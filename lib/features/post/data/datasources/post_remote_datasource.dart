import 'package:chopper/chopper.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/auth/data/models/api_error_model.dart';
import 'package:motodi_go_mobile/features/post/data/models/post_models.dart';

abstract class PostRemoteDataSource {
  Future<TripHistoryPageModel> getTripHistory({
    required String tab,
    String? from,
    String? to,
    String? status,
    String? paymentStatus,
    String? tripType,
    int page = 0,
    int size = 20,
  });

  Future<List<TripRatingModel>> getTripRatings(String tripId);

  Future<TripRatingModel> submitRating({
    required String tripId,
    required String ratedProfileId,
    required int stars,
    String? comment,
    List<String> tags = const [],
  });

  Future<ReceiptPageModel> getReceipts({int page = 0, int size = 20});

  Future<PostReceiptModel> getReceipt(String id);

  Future<SupportTicketModel> createSupportTicket({
    required String category,
    required String priority,
    required String subject,
    required String message,
    String? tripId,
    String? bookingId,
    String? paymentTransactionId,
  });

  Future<SupportTicketPageModel> getSupportTickets({
    String? status,
    int page = 0,
    int size = 20,
  });

  Future<SupportTicketModel> getSupportTicket(String id);
}

@LazySingleton(as: PostRemoteDataSource)
class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final ChopperClient _client;

  PostRemoteDataSourceImpl(this._client);

  @override
  Future<TripHistoryPageModel> getTripHistory({
    required String tab,
    String? from,
    String? to,
    String? status,
    String? paymentStatus,
    String? tripType,
    int page = 0,
    int size = 20,
  }) async {
    final parameters = <String, String>{
      'tab': tab,
      'page': '$page',
      'size': '$size',
    };
    if (from != null && from.isNotEmpty) parameters['from'] = from;
    if (to != null && to.isNotEmpty) parameters['to'] = to;
    if (status != null && status.isNotEmpty) parameters['status'] = status;
    if (paymentStatus != null && paymentStatus.isNotEmpty) {
      parameters['paymentStatus'] = paymentStatus;
    }
    if (tripType != null && tripType.isNotEmpty) parameters['tripType'] = tripType;

    final response = await _client.get<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/trips/history'),
      parameters: parameters,
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return TripHistoryPageModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<List<TripRatingModel>> getTripRatings(String tripId) async {
    final response = await _client.get<dynamic, dynamic>(Uri.parse('/trips/$tripId/ratings'));
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    final body = response.body;
    if (body is List) {
      return body
          .whereType<Map>()
          .map((item) => TripRatingModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    if (body is Map) {
      final ratings = body['ratings'] ?? body['items'];
      if (ratings is List) {
        return ratings
            .whereType<Map>()
            .map((item) => TripRatingModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    }
    return const [];
  }

  @override
  Future<TripRatingModel> submitRating({
    required String tripId,
    required String ratedProfileId,
    required int stars,
    String? comment,
    List<String> tags = const [],
  }) async {
    final body = <String, dynamic>{
      'ratedProfileId': ratedProfileId,
      'stars': stars,
      if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
      if (tags.isNotEmpty) 'tags': tags,
    };
    final response = await _client.post<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/trips/$tripId/ratings'),
      body: body,
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return TripRatingModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<ReceiptPageModel> getReceipts({int page = 0, int size = 20}) async {
    final response = await _client.get<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/receipts'),
      parameters: {'page': '$page', 'size': '$size'},
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return ReceiptPageModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<PostReceiptModel> getReceipt(String id) async {
    final response = await _client.get<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/receipts/$id'),
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return PostReceiptModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<SupportTicketModel> createSupportTicket({
    required String category,
    required String priority,
    required String subject,
    required String message,
    String? tripId,
    String? bookingId,
    String? paymentTransactionId,
  }) async {
    final body = <String, dynamic>{
      'category': category,
      'priority': priority,
      'subject': subject,
      'message': message,
      if (tripId != null && tripId.isNotEmpty) 'tripId': tripId,
      if (bookingId != null && bookingId.isNotEmpty) 'bookingId': bookingId,
      if (paymentTransactionId != null && paymentTransactionId.isNotEmpty)
        'paymentTransactionId': paymentTransactionId,
    };
    final response = await _client.post<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/support/tickets'),
      body: body,
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return SupportTicketModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<SupportTicketPageModel> getSupportTickets({
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    final parameters = <String, String>{'page': '$page', 'size': '$size'};
    if (status != null && status.isNotEmpty) parameters['status'] = status;
    final response = await _client.get<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/support/tickets'),
      parameters: parameters,
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return SupportTicketPageModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<SupportTicketModel> getSupportTicket(String id) async {
    final response = await _client.get<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/support/tickets/$id'),
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return SupportTicketModel.fromJson(response.body ?? <String, dynamic>{});
  }
}
