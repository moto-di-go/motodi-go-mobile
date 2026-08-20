import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/core/network/network_info.dart';
import 'package:motodi_go_mobile/features/auth/data/models/api_error_model.dart';
import 'package:motodi_go_mobile/features/intercity/data/datasources/intercity_remote_datasource.dart';
import 'package:motodi_go_mobile/features/intercity/data/models/intercity_models.dart';
import 'package:motodi_go_mobile/features/intercity/data/repositories/intercity_repository_impl.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/search_filters.dart';

import '../../intercity_fixtures.dart';

class MockIntercityRemoteDataSource extends Mock implements IntercityRemoteDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockIntercityRemoteDataSource remote;
  late MockNetworkInfo network;
  late IntercityRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const SearchFilters());
    registerFallbackValue(
      CreateAnnouncementPayload(
        departureCity: 'Yaoundé',
        destinationCity: 'Douala',
        departureDate: DateTime(2026, 8, 21),
        departureTime: '08:00:00',
        priceFcfa: 5000,
        totalSeats: 4,
        vehicleId: 'veh-1',
      ),
    );
  });

  setUp(() {
    remote = MockIntercityRemoteDataSource();
    network = MockNetworkInfo();
    repository = IntercityRepositoryImpl(remote, network);
  });

  test('returns NetworkFailure while offline', () async {
    when(() => network.isConnected).thenAnswer((_) async => false);

    final result = await repository.searchAnnouncements(const SearchFilters());

    expect(result.isLeft(), isTrue);
    result.fold((failure) => expect(failure, isA<NetworkFailure>()), (_) => fail('no data'));
    verifyNever(() => remote.searchAnnouncements(any()));
  });

  test('searchAnnouncements maps remote page', () async {
    when(() => network.isConnected).thenAnswer((_) async => true);
    when(
      () => remote.searchAnnouncements(
        any(),
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer(
      (_) async => AnnouncementSearchPageModel.fromJson({
        'items': [announcementJson()],
        'page': 0,
        'size': 20,
        'hasMore': false,
      }),
    );

    final result = await repository.searchAnnouncements(const SearchFilters());

    expect(result.isRight(), isTrue);
    result.fold((_) => fail('expected data'), (page) {
      expect(page.items, hasLength(1));
      expect(page.items.single.id, 'ann-1');
    });
  });

  test('createAnnouncement and listMyVehicles succeed', () async {
    when(() => network.isConnected).thenAnswer((_) async => true);
    when(
      () => remote.createAnnouncement(any()),
    ).thenAnswer((_) async => IntercityAnnouncementModel.fromJson(announcementJson()));
    when(
      () => remote.listMyVehicles(),
    ).thenAnswer((_) async => [IntercityVehicleModel.fromJson(vehicleJson())]);

    final created = await repository.createAnnouncement(
      departureCity: 'Yaoundé',
      destinationCity: 'Douala',
      departureDate: DateTime(2026, 8, 21),
      departureTime: '08:30:00',
      priceFcfa: 7500,
      totalSeats: 4,
      vehicleId: 'veh-1',
    );
    final vehicles = await repository.listMyVehicles();

    expect(created.isRight(), isTrue);
    expect(vehicles.isRight(), isTrue);
    vehicles.fold((_) => fail('expected vehicles'), (list) => expect(list.single.isUsable, isTrue));
  });

  test('maps booking validation and auth API errors', () async {
    when(() => network.isConnected).thenAnswer((_) async => true);
    when(
      () => remote.createBooking(
        any(),
        seatsRequested: any(named: 'seatsRequested'),
        contactPhone: any(named: 'contactPhone'),
      ),
    ).thenThrow(const ApiException('NO_SEAT_AVAILABLE', 'Complet'));

    final validation = await repository.createBooking(
      announcementId: 'ann-1',
      seatsRequested: 2,
      contactPhone: '+237699001122',
    );
    validation.fold((failure) {
      expect(failure, isA<ValidationFailure>());
      expect(failure.code, 'NO_SEAT_AVAILABLE');
    }, (_) => fail('expected failure'));

    when(
      () => remote.confirmBooking(any()),
    ).thenThrow(const ApiException('BOOKING_FORBIDDEN', 'Interdit'));
    final auth = await repository.confirmBooking('book-1');
    auth.fold((failure) {
      expect(failure, isA<AuthFailure>());
      expect(failure.code, 'BOOKING_FORBIDDEN');
    }, (_) => fail('expected failure'));
  });

  test('getAnnouncement maps unexpected errors to ServerFailure', () async {
    when(() => network.isConnected).thenAnswer((_) async => true);
    when(() => remote.getAnnouncement(any())).thenThrow(Exception('boom'));

    final result = await repository.getAnnouncement('ann-1');
    result.fold(
      (failure) => expect(failure, isA<ServerFailure>()),
      (_) => fail('expected failure'),
    );
  });

  test('booking list and cancel map remote models', () async {
    when(() => network.isConnected).thenAnswer((_) async => true);
    when(
      () => remote.listMyBookings(
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer(
      (_) async => BookingPageModel.fromJson({
        'items': [bookingJson()],
        'page': 0,
        'size': 20,
        'hasMore': false,
      }),
    );
    when(
      () => remote.cancelBooking(any(), any()),
    ).thenAnswer((_) async => IntercityBookingModel.fromJson(bookingJson(status: 'CANCELLED')));
    when(() => remote.closeAnnouncement(any())).thenAnswer(
      (_) async => IntercityAnnouncementModel.fromJson(announcementJson(status: 'CLOSED')),
    );

    final page = await repository.listMyBookings();
    final cancelled = await repository.cancelBooking('book-1', 'changed plans');
    final closed = await repository.closeAnnouncement('ann-1');

    expect(page.isRight(), isTrue);
    expect(cancelled.isRight(), isTrue);
    expect(closed.isRight(), isTrue);
  });
}
