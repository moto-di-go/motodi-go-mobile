import 'package:flutter_test/flutter_test.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_announcement.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_booking.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_vehicle.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/search_filters.dart';

void main() {
  group('IntercityTimeSlot and sort', () {
    test('labels and time bounds', () {
      expect(IntercityTimeSlot.matin.label, 'Matin');
      expect(IntercityTimeSlot.matin.timeFrom, '05:00:00');
      expect(IntercityTimeSlot.matin.timeTo, '11:59:00');
      expect(IntercityTimeSlot.apresMidi.label, 'Après-midi');
      expect(IntercityTimeSlot.soir.timeFrom, '18:00:00');
      expect(IntercitySort.price.apiValue, 'price');
      expect(IntercitySort.departureTime.label, 'Heure de départ');
      expect(IntercitySort.proximity.label, 'Proximité');
    });
  });

  group('SearchFilters', () {
    test('counts active filters and route presence', () {
      const empty = SearchFilters();
      expect(empty.hasRoute, isFalse);
      expect(empty.activeFilterCount, 0);

      final filters = empty.copyWith(
        departureCity: 'Yaoundé',
        destinationCity: 'Douala',
        date: DateTime(2026, 8, 21),
        seats: 3,
        maxPrice: 8000,
        timeSlot: IntercityTimeSlot.matin,
        ptRamassage: 'Bastos',
        onlyVerified: true,
        onlyAvailable: false,
        sort: IntercitySort.price,
      );
      expect(filters.hasRoute, isTrue);
      expect(filters.activeFilterCount, 8);

      final cleared = filters.clearAdvancedFilters();
      expect(cleared.departureCity, 'Yaoundé');
      expect(cleared.maxPrice, isNull);
      expect(cleared.onlyAvailable, isTrue);
    });

    test('clears individual fields and applies widening query', () {
      final filters = const SearchFilters(
        departureCity: 'Yaoundé',
        date: null,
        maxPrice: 5000,
        timeSlot: IntercityTimeSlot.soir,
        ptRamassage: 'Bastos',
      ).copyWith(clearDepartureCity: true, date: DateTime(2026, 8, 21));

      expect(filters.departureCity, isNull);
      expect(filters.date, DateTime(2026, 8, 21));

      final widened = filters.applyingWidening({
        'destinationCity': 'Kribi',
        'date': '2026-08-22',
        'maxPrice': 9000,
        'timeSlot': null,
        'ptRamassage': null,
      });
      expect(widened.destinationCity, 'Kribi');
      expect(widened.date, DateTime.parse('2026-08-22'));
      expect(widened.maxPrice, 9000);
      expect(widened.timeSlot, isNull);
    });
  });

  group('announcement and booking entities', () {
    test('AnnouncementStatus mapping and announcement helpers', () {
      expect(AnnouncementStatus.fromApi('full'), AnnouncementStatus.full);
      expect(AnnouncementStatus.fromApi('nope'), AnnouncementStatus.unknown);
      expect(AnnouncementStatus.published.apiValue, 'PUBLISHED');
      expect(AnnouncementStatus.closed.label, 'Clôturée');
      expect(AnnouncementStatus.published.isActive, isTrue);
      expect(AnnouncementStatus.cancelled.isActive, isFalse);

      final announcement = IntercityAnnouncement(
        id: 'a',
        publisherProfileId: 'p',
        departureCity: 'Yaoundé',
        destinationCity: 'Douala',
        departureDate: DateTime(2026, 8, 21),
        departureTime: '8:05:00',
        priceFcfa: 1,
        totalSeats: 4,
        remainingSeats: 1,
        status: AnnouncementStatus.published,
        departureLat: 3.8,
        departureLon: 11.5,
      );
      expect(announcement.hasSeatsAvailable, isTrue);
      expect(announcement.formattedDepartureTime, '08:05');
      expect(announcement.departureMinutesOfDay, 8 * 60 + 5);
      expect(announcement.route, 'Yaoundé → Douala');
      expect(announcement.hasGeoPoint, isTrue);
      expect(AnnouncementPage.empty.items, isEmpty);
    });

    test('IntercityBookingStatus and passenger display helpers', () {
      expect(
        IntercityBookingStatus.fromApi('PENDING_PAYMENT'),
        IntercityBookingStatus.pendingPayment,
      );
      expect(IntercityBookingStatus.paid.isFinal, isTrue);
      expect(IntercityBookingStatus.pending.isCancellable, isTrue);
      expect(IntercityBookingStatus.confirmed.label, 'Confirmée');
      expect(IntercityBookingStatus.pending.longLabel, 'Demande envoyée');
      expect(IntercityBookingStatus.unknown.apiValue, 'UNKNOWN');

      final named = IntercityBooking(
        id: 'b',
        announcementId: 'a',
        passengerProfileId: 'p',
        status: IntercityBookingStatus.pending,
        seatsRequested: 1,
        contactPhone: '+237699001122',
        passengerDisplayName: 'Marie Nguema',
        expiresAt: DateTime.now().add(const Duration(minutes: 2)),
      );
      expect(named.shortPassengerName, 'Marie N.');
      expect(named.passengerInitials, 'MN');
      expect(named.isExpiringSoon, isTrue);

      final anonymous = IntercityBooking(
        id: 'b2',
        announcementId: 'a',
        passengerProfileId: 'p',
        status: IntercityBookingStatus.paid,
        seatsRequested: 1,
        contactPhone: '+237699001122',
      );
      expect(anonymous.shortPassengerName, 'Voyageur 22');
      expect(anonymous.isExpiringSoon, isFalse);
      expect(BookingPage.empty.hasMore, isFalse);
    });

    test('vehicle usability', () {
      const usable = IntercityVehicle(
        id: 'v',
        ownerProfileId: 'o',
        type: 'MINIBUS',
        validationStatus: 'validated',
        active: true,
        photoUrl: '',
      );
      expect(usable.isUsable, isTrue);
      expect(
        const IntercityVehicle(
          id: 'v',
          ownerProfileId: 'o',
          type: 'MINIBUS',
          validationStatus: 'PENDING',
          active: true,
          photoUrl: '',
        ).isUsable,
        isFalse,
      );
    });
  });
}
