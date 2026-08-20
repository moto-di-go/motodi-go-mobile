import 'package:flutter_test/flutter_test.dart';
import 'package:motodi_go_mobile/features/intercity/data/models/intercity_models.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_announcement.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_booking.dart';

import '../../intercity_fixtures.dart';

void main() {
  test('parses announcement search page with widening suggestions', () {
    final model = AnnouncementSearchPageModel.fromJson({
      'items': [announcementJson()],
      'page': 0,
      'size': 20,
      'hasMore': true,
      'wideningSuggestions': [
        {
          'code': 'RELAX_DATE',
          'message': 'Élargir la date',
          'suggestedQuery': {'date': '2026-08-22'},
        },
      ],
    });

    final entity = model.toEntity();
    expect(entity.items.single.departureCity, 'Yaoundé');
    expect(entity.items.single.status, AnnouncementStatus.published);
    expect(entity.hasMore, isTrue);
    expect(entity.wideningSuggestions.single.code, 'RELAX_DATE');
    expect(entity.isEmpty, isFalse);
  });

  test('parses empty search page and missing suggestedQuery map', () {
    final model = AnnouncementSearchPageModel.fromJson({
      'items': [],
      'wideningSuggestions': [
        {'code': 'INCLUDE_FULL', 'message': 'Inclure les complets'},
      ],
    });
    final entity = model.toEntity();
    expect(entity.isEmpty, isTrue);
    expect(entity.wideningSuggestions.single.suggestedQuery, isEmpty);
  });

  test('parses announcement page, booking page and vehicle', () {
    final announcements = AnnouncementPageModel.fromJson({
      'items': [announcementJson(status: 'CLOSED')],
      'page': 1,
      'size': 10,
      'hasMore': false,
    }).toEntity();
    expect(announcements.items.single.status, AnnouncementStatus.closed);
    expect(announcements.page, 1);

    final bookings = BookingPageModel.fromJson({
      'items': [bookingJson(status: 'CONFIRMED')],
      'page': 0,
      'size': 20,
      'hasMore': false,
    }).toEntity();
    expect(bookings.items.single.status, IntercityBookingStatus.confirmed);

    final vehicle = IntercityVehicleModel.fromJson(vehicleJson()).toEntity();
    expect(vehicle.isUsable, isTrue);
    expect(vehicle.capacity, 18);
  });

  test('CreateAnnouncementPayload omits empty optionals and serializes points', () {
    final payload = CreateAnnouncementPayload(
      departureCity: 'Yaoundé',
      destinationCity: 'Douala',
      ptRamassage: 'Bastos',
      departureLat: 3.87,
      departureLon: 11.52,
      destinationLat: 4.05,
      destinationLon: 9.7,
      departureDate: DateTime(2026, 8, 21),
      departureTime: '08:30:00',
      priceFcfa: 7500,
      totalSeats: 4,
      vehicleId: 'veh-1',
      instructions: 'OK',
    );

    final json = payload.toJson();
    expect(json['departureDate'], '2026-08-21');
    expect(json['ptRamassage'], 'Bastos');
    expect(json['departurePoint'], {'latitude': 3.87, 'longitude': 11.52});
    expect(json['destinationPoint'], {'latitude': 4.05, 'longitude': 9.7});
    expect(json['instructions'], 'OK');

    final minimal = CreateAnnouncementPayload(
      departureCity: 'Yaoundé',
      destinationCity: 'Douala',
      ptRamassage: '',
      departureDate: DateTime(2026, 1, 5),
      departureTime: '09:00:00',
      priceFcfa: 1000,
      totalSeats: 1,
      vehicleId: 'veh-1',
      instructions: '',
    ).toJson();
    expect(minimal.containsKey('ptRamassage'), isFalse);
    expect(minimal.containsKey('departurePoint'), isFalse);
    expect(minimal.containsKey('instructions'), isFalse);
    expect(minimal['departureDate'], '2026-01-05');
  });

  test('announcement model falls back on missing fields', () {
    final entity = IntercityAnnouncementModel.fromJson({'id': 'x'}).toEntity();
    expect(entity.publisherProfileId, isEmpty);
    expect(entity.status, AnnouncementStatus.unknown);
    expect(entity.departureTime, '00:00:00');
  });
}
