import 'package:chopper/chopper.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/auth/data/models/api_error_model.dart';
import 'package:motodi_go_mobile/features/intercity/data/models/intercity_models.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/search_filters.dart';

abstract class IntercityRemoteDataSource {
  Future<AnnouncementSearchPageModel> searchAnnouncements(
    SearchFilters filters, {
    int page = 0,
    int size = 20,
  });

  Future<AnnouncementPageModel> listMyAnnouncements({int page = 0, int size = 20});

  Future<IntercityAnnouncementModel> getAnnouncement(String id);

  Future<IntercityAnnouncementModel> createAnnouncement(CreateAnnouncementPayload payload);

  Future<IntercityAnnouncementModel> closeAnnouncement(String id);

  Future<IntercityAnnouncementModel> cancelAnnouncement(String id);

  Future<IntercityBookingModel> createBooking(
    String announcementId, {
    required int seatsRequested,
    required String contactPhone,
  });

  Future<BookingPageModel> listAnnouncementBookings(String announcementId, {int page = 0, int size = 20});

  Future<BookingPageModel> listMyBookings({int page = 0, int size = 20});

  Future<IntercityBookingModel> getBooking(String id);

  Future<IntercityBookingModel> confirmBooking(String id);

  Future<IntercityBookingModel> cancelBooking(String id, String cancellationReason);

  Future<List<IntercityVehicleModel>> listMyVehicles();
}

@LazySingleton(as: IntercityRemoteDataSource)
class IntercityRemoteDataSourceImpl implements IntercityRemoteDataSource {
  final ChopperClient _client;

  IntercityRemoteDataSourceImpl(this._client);

  @override
  Future<AnnouncementSearchPageModel> searchAnnouncements(
    SearchFilters filters, {
    int page = 0,
    int size = 20,
  }) async {
    // All query values as String so Chopper builds the same query as OpenAPI/Swagger.
    final params = <String, dynamic>{
      'page': '$page',
      'size': '$size',
      'onlyAvailable': '${filters.onlyAvailable}',
      'sort': filters.sort.apiValue,
    };
    final departure = filters.departureCity?.trim();
    if (departure != null && departure.isNotEmpty) {
      params['departureCity'] = departure;
    }
    final destination = filters.destinationCity?.trim();
    if (destination != null && destination.isNotEmpty) {
      params['destinationCity'] = destination;
    }
    if (filters.date != null) {
      params['date'] = _isoDate(filters.date!);
    }
    if (filters.maxPrice != null) {
      params['maxPrice'] = '${filters.maxPrice!.round()}';
    }
    if (filters.timeSlot != null) {
      params['timeFrom'] = filters.timeSlot!.timeFrom;
      params['timeTo'] = filters.timeSlot!.timeTo;
    }
    final ptRamassage = filters.ptRamassage?.trim();
    if (ptRamassage != null && ptRamassage.isNotEmpty) {
      params['ptRamassage'] = ptRamassage;
    }
    final response = await _client.get<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/intercity/announcements'),
      parameters: params,
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return AnnouncementSearchPageModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<AnnouncementPageModel> listMyAnnouncements({int page = 0, int size = 20}) async {
    final response = await _client.get<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/intercity/announcements/mine'),
      parameters: {'page': page, 'size': size},
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return AnnouncementPageModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<IntercityAnnouncementModel> getAnnouncement(String id) async {
    final response = await _client.get<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/intercity/announcements/$id'),
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return IntercityAnnouncementModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<IntercityAnnouncementModel> createAnnouncement(CreateAnnouncementPayload payload) async {
    final response = await _client.post<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/intercity/announcements'),
      body: payload.toJson(),
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return IntercityAnnouncementModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<IntercityAnnouncementModel> closeAnnouncement(String id) async {
    final response = await _client.post<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/intercity/announcements/$id/close'),
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return IntercityAnnouncementModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<IntercityAnnouncementModel> cancelAnnouncement(String id) async {
    final response = await _client.post<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/intercity/announcements/$id/cancel'),
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return IntercityAnnouncementModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<IntercityBookingModel> createBooking(
    String announcementId, {
    required int seatsRequested,
    required String contactPhone,
  }) async {
    final response = await _client.post<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/intercity/announcements/$announcementId/bookings'),
      body: {'seatsRequested': seatsRequested, 'contactPhone': contactPhone},
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return IntercityBookingModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<BookingPageModel> listAnnouncementBookings(
    String announcementId, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await _client.get<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/intercity/announcements/$announcementId/bookings'),
      parameters: {'page': page, 'size': size},
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return BookingPageModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<BookingPageModel> listMyBookings({int page = 0, int size = 20}) async {
    final response = await _client.get<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/bookings/mine'),
      parameters: {'page': page, 'size': size},
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return BookingPageModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<IntercityBookingModel> getBooking(String id) async {
    final response = await _client.get<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/bookings/$id'),
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return IntercityBookingModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<IntercityBookingModel> confirmBooking(String id) async {
    final response = await _client.post<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/bookings/$id/confirm'),
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return IntercityBookingModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<IntercityBookingModel> cancelBooking(String id, String cancellationReason) async {
    final response = await _client.post<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/bookings/$id/cancel'),
      body: {'cancellationReason': cancellationReason},
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return IntercityBookingModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<List<IntercityVehicleModel>> listMyVehicles() async {
    final response = await _client.get<List<dynamic>, Map<String, dynamic>>(
      Uri.parse('/vehicles/mine'),
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return (response.body ?? [])
        .map((value) => IntercityVehicleModel.fromJson(Map<String, dynamic>.from(value as Map)))
        .toList();
  }

  String _isoDate(DateTime date) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${date.year.toString().padLeft(4, '0')}-${twoDigits(date.month)}-${twoDigits(date.day)}';
  }
}
