import 'package:bloc_test/bloc_test.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_booking.dart';
import 'package:motodi_go_mobile/features/intercity/domain/repositories/intercity_repository.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/cubit/intercity_booking_cubit.dart';

import '../../intercity_fixtures.dart';

class MockIntercityRepository extends Mock implements IntercityRepository {}

ChopperClient _client() => ChopperClient(baseUrl: Uri.parse('http://127.0.0.1:9'));

void main() {
  late MockIntercityRepository repository;

  setUp(() {
    repository = MockIntercityRepository();
  });

  blocTest<IntercityBookingCubit, IntercityBookingState>(
    'loadDetail emits announcement then itinerary failure without urban API',
    build: () {
      when(
        () => repository.getAnnouncement(any()),
      ).thenAnswer((_) async => right(announcementEntity()));
      return IntercityBookingCubit(repository, _client());
    },
    act: (cubit) => cubit.loadDetail('ann-1'),
    expect: () => [
      isA<IntercityBookingState>().having(
        (s) => s.detailStatus,
        'detail',
        IntercityDetailStatus.loading,
      ),
      isA<IntercityBookingState>()
          .having((s) => s.detailStatus, 'detail', IntercityDetailStatus.success)
          .having((s) => s.announcement?.id, 'id', 'ann-1'),
      isA<IntercityBookingState>().having(
        (s) => s.itineraryStatus,
        'itinerary',
        IntercityItineraryStatus.loading,
      ),
      isA<IntercityBookingState>().having(
        (s) => s.itineraryStatus,
        'itinerary',
        IntercityItineraryStatus.failure,
      ),
    ],
  );

  blocTest<IntercityBookingCubit, IntercityBookingState>(
    'subscribe emits created booking',
    build: () {
      when(
        () => repository.createBooking(
          announcementId: any(named: 'announcementId'),
          seatsRequested: any(named: 'seatsRequested'),
          contactPhone: any(named: 'contactPhone'),
        ),
      ).thenAnswer((_) async => right(bookingEntity()));
      return IntercityBookingCubit(repository, _client());
    },
    act: (cubit) =>
        cubit.subscribe(announcementId: 'ann-1', seatsRequested: 2, contactPhone: '+237699001122'),
    expect: () => [
      isA<IntercityBookingState>().having(
        (s) => s.subscribeStatus,
        'status',
        IntercitySubscribeStatus.submitting,
      ),
      isA<IntercityBookingState>()
          .having((s) => s.subscribeStatus, 'status', IntercitySubscribeStatus.success)
          .having((s) => s.createdBooking?.id, 'id', 'book-1'),
    ],
  );

  blocTest<IntercityBookingCubit, IntercityBookingState>(
    'subscribe emits failure',
    build: () {
      when(
        () => repository.createBooking(
          announcementId: any(named: 'announcementId'),
          seatsRequested: any(named: 'seatsRequested'),
          contactPhone: any(named: 'contactPhone'),
        ),
      ).thenAnswer(
        (_) async => left(const ValidationFailure('Complet', code: 'NO_SEAT_AVAILABLE')),
      );
      return IntercityBookingCubit(repository, _client());
    },
    act: (cubit) =>
        cubit.subscribe(announcementId: 'ann-1', seatsRequested: 2, contactPhone: '+237699001122'),
    expect: () => [
      isA<IntercityBookingState>().having(
        (s) => s.subscribeStatus,
        'status',
        IntercitySubscribeStatus.submitting,
      ),
      isA<IntercityBookingState>()
          .having((s) => s.subscribeStatus, 'status', IntercitySubscribeStatus.failure)
          .having((s) => s.subscribeErrorCode, 'code', 'NO_SEAT_AVAILABLE'),
    ],
  );

  blocTest<IntercityBookingCubit, IntercityBookingState>(
    'loadMyBookings and loadBooking',
    build: () {
      when(
        () => repository.listMyBookings(
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer(
        (_) async =>
            right(BookingPage(items: [bookingEntity()], page: 0, size: 20, hasMore: false)),
      );
      when(() => repository.getBooking(any())).thenAnswer((_) async => right(bookingEntity()));
      when(
        () => repository.getAnnouncement(any()),
      ).thenAnswer((_) async => right(announcementEntity()));
      return IntercityBookingCubit(repository, _client());
    },
    act: (cubit) async {
      await cubit.loadMyBookings();
      await cubit.loadBooking('book-1');
    },
    expect: () => [
      isA<IntercityBookingState>().having(
        (s) => s.myBookingsStatus,
        'status',
        IntercityBookingsStatus.loading,
      ),
      isA<IntercityBookingState>().having((s) => s.myBookings, 'items', hasLength(1)),
      isA<IntercityBookingState>().having(
        (s) => s.bookingStatus,
        'status',
        IntercityBookingsStatus.loading,
      ),
      isA<IntercityBookingState>().having((s) => s.booking?.id, 'booking', 'book-1'),
      isA<IntercityBookingState>().having((s) => s.announcement?.id, 'announcement', 'ann-1'),
    ],
  );

  test('cancelBooking returns true and updates state', () async {
    when(
      () => repository.cancelBooking(any(), any()),
    ).thenAnswer((_) async => right(bookingEntity(status: IntercityBookingStatus.cancelled)));
    final cubit = IntercityBookingCubit(repository, _client());

    final ok = await cubit.cancelBooking('book-1', 'changed');

    expect(ok, isTrue);
    expect(cubit.state.booking?.status, IntercityBookingStatus.cancelled);
    await cubit.close();
  });
}
