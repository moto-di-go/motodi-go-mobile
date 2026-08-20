import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_announcement.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_booking.dart';
import 'package:motodi_go_mobile/features/intercity/domain/repositories/intercity_repository.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/cubit/intercity_publish_cubit.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';
import 'package:motodi_go_mobile/features/profiles/domain/repositories/profile_repository.dart';

import '../../intercity_fixtures.dart';

class MockIntercityRepository extends Mock implements IntercityRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockIntercityRepository repository;
  late MockProfileRepository profiles;

  setUpAll(() {
    registerFallbackValue(DateTime(2026, 8, 21));
  });

  setUp(() {
    repository = MockIntercityRepository();
    profiles = MockProfileRepository();
  });

  blocTest<IntercityPublishCubit, IntercityPublishState>(
    'checkEligibility succeeds for validated mototaxi with usable vehicle',
    build: () {
      when(() => profiles.currentProfile()).thenAnswer((_) async => right(publisherProfile()));
      when(() => repository.listMyVehicles()).thenAnswer((_) async => right([vehicleEntity()]));
      return IntercityPublishCubit(repository, profiles);
    },
    act: (cubit) => cubit.checkEligibility(),
    expect: () => [
      isA<IntercityPublishState>().having(
        (s) => s.eligibilityStatus,
        'status',
        IntercityEligibilityStatus.checking,
      ),
      isA<IntercityPublishState>().having(
        (s) => s.vehiclesStatus,
        'vehicles',
        IntercityVehiclesStatus.success,
      ),
      isA<IntercityPublishState>().having(
        (s) => s.eligibilityStatus,
        'status',
        IntercityEligibilityStatus.eligible,
      ),
    ],
  );

  blocTest<IntercityPublishCubit, IntercityPublishState>(
    'checkEligibility rejects passenger profiles',
    build: () {
      when(
        () => profiles.currentProfile(),
      ).thenAnswer((_) async => right(publisherProfile(type: ProfileType.passenger)));
      return IntercityPublishCubit(repository, profiles);
    },
    act: (cubit) => cubit.checkEligibility(),
    expect: () => [
      isA<IntercityPublishState>().having(
        (s) => s.eligibilityStatus,
        'status',
        IntercityEligibilityStatus.checking,
      ),
      isA<IntercityPublishState>()
          .having((s) => s.eligibilityStatus, 'status', IntercityEligibilityStatus.ineligible)
          .having((s) => s.eligibilityReason, 'reason', contains('transporteur')),
    ],
  );

  blocTest<IntercityPublishCubit, IntercityPublishState>(
    'createAnnouncement emits success',
    build: () {
      when(
        () => repository.createAnnouncement(
          departureCity: any(named: 'departureCity'),
          destinationCity: any(named: 'destinationCity'),
          ptRamassage: any(named: 'ptRamassage'),
          departureLat: any(named: 'departureLat'),
          departureLon: any(named: 'departureLon'),
          destinationLat: any(named: 'destinationLat'),
          destinationLon: any(named: 'destinationLon'),
          departureDate: any(named: 'departureDate'),
          departureTime: any(named: 'departureTime'),
          priceFcfa: any(named: 'priceFcfa'),
          totalSeats: any(named: 'totalSeats'),
          vehicleId: any(named: 'vehicleId'),
          instructions: any(named: 'instructions'),
        ),
      ).thenAnswer((_) async => right(announcementEntity()));
      return IntercityPublishCubit(repository, profiles);
    },
    act: (cubit) => cubit.createAnnouncement(
      departureCity: 'Yaoundé',
      destinationCity: 'Douala',
      departureDate: DateTime(2026, 8, 21),
      departureTime: '08:30:00',
      priceFcfa: 7500,
      totalSeats: 4,
      vehicleId: 'veh-1',
    ),
    expect: () => [
      isA<IntercityPublishState>().having(
        (s) => s.createStatus,
        'status',
        IntercityCreateStatus.submitting,
      ),
      isA<IntercityPublishState>()
          .having((s) => s.createStatus, 'status', IntercityCreateStatus.success)
          .having((s) => s.createdAnnouncement?.id, 'id', 'ann-1'),
    ],
  );

  blocTest<IntercityPublishCubit, IntercityPublishState>(
    'loadMyAnnouncements and closeAnnouncement update list',
    build: () {
      when(
        () => repository.listMyAnnouncements(
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer(
        (_) async => right(
          AnnouncementPage(items: [announcementEntity()], page: 0, size: 20, hasMore: false),
        ),
      );
      when(
        () => repository.closeAnnouncement(any()),
      ).thenAnswer((_) async => right(announcementEntity(status: AnnouncementStatus.closed)));
      return IntercityPublishCubit(repository, profiles);
    },
    act: (cubit) async {
      await cubit.loadMyAnnouncements();
      await cubit.closeAnnouncement('ann-1');
    },
    expect: () => [
      isA<IntercityPublishState>().having(
        (s) => s.mineStatus,
        'status',
        IntercityMineStatus.loading,
      ),
      isA<IntercityPublishState>().having((s) => s.myAnnouncements, 'items', hasLength(1)),
      isA<IntercityPublishState>().having(
        (s) => s.myAnnouncements.single.status,
        'status',
        AnnouncementStatus.closed,
      ),
    ],
  );

  blocTest<IntercityPublishCubit, IntercityPublishState>(
    'loadIncomingBookings and confirmIncomingBooking',
    build: () {
      when(
        () => repository.getAnnouncement(any()),
      ).thenAnswer((_) async => right(announcementEntity()));
      when(
        () => repository.listAnnouncementBookings(
          any(),
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer(
        (_) async =>
            right(BookingPage(items: [bookingEntity()], page: 0, size: 20, hasMore: false)),
      );
      when(
        () => repository.confirmBooking(any()),
      ).thenAnswer((_) async => right(bookingEntity(status: IntercityBookingStatus.confirmed)));
      return IntercityPublishCubit(repository, profiles);
    },
    act: (cubit) async {
      await cubit.loadIncomingBookings('ann-1');
      await cubit.confirmIncomingBooking('book-1');
    },
    expect: () => [
      isA<IntercityPublishState>().having(
        (s) => s.incomingStatus,
        'status',
        IntercityIncomingStatus.loading,
      ),
      isA<IntercityPublishState>()
          .having((s) => s.incomingStatus, 'status', IntercityIncomingStatus.success)
          .having((s) => s.incomingBookings, 'bookings', hasLength(1)),
      isA<IntercityPublishState>().having((s) => s.processingBookingIds, 'processing', {'book-1'}),
      isA<IntercityPublishState>().having(
        (s) => s.incomingBookings.single.status,
        'status',
        IntercityBookingStatus.confirmed,
      ),
      isA<IntercityPublishState>().having((s) => s.processingBookingIds, 'processing', isEmpty),
    ],
  );

  blocTest<IntercityPublishCubit, IntercityPublishState>(
    'loadVehicles emits failure',
    build: () {
      when(
        () => repository.listMyVehicles(),
      ).thenAnswer((_) async => left(const ServerFailure('down')));
      return IntercityPublishCubit(repository, profiles);
    },
    act: (cubit) => cubit.loadVehicles(),
    expect: () => [
      isA<IntercityPublishState>().having(
        (s) => s.vehiclesStatus,
        'status',
        IntercityVehiclesStatus.loading,
      ),
      isA<IntercityPublishState>().having(
        (s) => s.vehiclesStatus,
        'status',
        IntercityVehiclesStatus.failure,
      ),
    ],
  );
}
