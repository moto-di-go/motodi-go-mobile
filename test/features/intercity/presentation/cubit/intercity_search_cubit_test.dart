import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/search_filters.dart';
import 'package:motodi_go_mobile/features/intercity/domain/repositories/intercity_repository.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/cubit/intercity_search_cubit.dart';

import '../../intercity_fixtures.dart';

class MockIntercityRepository extends Mock implements IntercityRepository {}

void main() {
  late MockIntercityRepository repository;

  setUpAll(() {
    registerFallbackValue(const SearchFilters());
  });

  setUp(() {
    repository = MockIntercityRepository();
  });

  blocTest<IntercitySearchCubit, IntercitySearchState>(
    'setDepartureCity and setSeats update filters',
    build: () => IntercitySearchCubit(repository),
    act: (cubit) {
      cubit.setDepartureCity('  Yaoundé  ');
      cubit.setDestinationCity('');
      cubit.setSeats(3);
      cubit.setSeats(0);
    },
    expect: () => [
      isA<IntercitySearchState>().having(
        (state) => state.filters.departureCity,
        'departure',
        'Yaoundé',
      ),
      isA<IntercitySearchState>().having((state) => state.filters.destinationCity, 'dest', isNull),
      isA<IntercitySearchState>().having((state) => state.filters.seats, 'seats', 3),
    ],
  );

  blocTest<IntercitySearchCubit, IntercitySearchState>(
    'search emits success page',
    build: () {
      when(
        () => repository.searchAnnouncements(
          any(),
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer(
        (_) async => right(
          AnnouncementSearchResult(items: [announcementEntity()], page: 0, size: 20, hasMore: true),
        ),
      );
      return IntercitySearchCubit(repository);
    },
    act: (cubit) => cubit.search(),
    expect: () => [
      isA<IntercitySearchState>().having((s) => s.status, 'status', IntercitySearchStatus.loading),
      isA<IntercitySearchState>()
          .having((s) => s.status, 'status', IntercitySearchStatus.success)
          .having((s) => s.results, 'results', hasLength(1))
          .having((s) => s.hasMore, 'hasMore', isTrue),
    ],
  );

  blocTest<IntercitySearchCubit, IntercitySearchState>(
    'search emits failure',
    build: () {
      when(
        () => repository.searchAnnouncements(
          any(),
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer((_) async => left(const ServerFailure('down', code: 'SERVER')));
      return IntercitySearchCubit(repository);
    },
    act: (cubit) => cubit.search(),
    expect: () => [
      isA<IntercitySearchState>().having((s) => s.status, 'status', IntercitySearchStatus.loading),
      isA<IntercitySearchState>()
          .having((s) => s.status, 'status', IntercitySearchStatus.failure)
          .having((s) => s.errorCode, 'code', 'SERVER'),
    ],
  );

  blocTest<IntercitySearchCubit, IntercitySearchState>(
    'loadMore appends results',
    build: () {
      when(
        () => repository.searchAnnouncements(
          any(),
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer(
        (_) async => right(
          AnnouncementSearchResult(
            items: [announcementEntity(id: 'ann-2')],
            page: 1,
            size: 20,
            hasMore: false,
          ),
        ),
      );
      return IntercitySearchCubit(repository);
    },
    seed: () => IntercitySearchState(
      status: IntercitySearchStatus.success,
      results: [announcementEntity()],
      hasMore: true,
    ),
    act: (cubit) => cubit.loadMore(),
    expect: () => [
      isA<IntercitySearchState>().having(
        (s) => s.status,
        'status',
        IntercitySearchStatus.loadingMore,
      ),
      isA<IntercitySearchState>()
          .having((s) => s.results, 'results', hasLength(2))
          .having((s) => s.hasMore, 'hasMore', isFalse),
    ],
  );

  blocTest<IntercitySearchCubit, IntercitySearchState>(
    'applyWideningSuggestion relaxes date then searches',
    build: () {
      when(
        () => repository.searchAnnouncements(
          any(),
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer(
        (_) async =>
            right(const AnnouncementSearchResult(items: [], page: 0, size: 20, hasMore: false)),
      );
      return IntercitySearchCubit(repository);
    },
    seed: () =>
        IntercitySearchState(filters: SearchFilters(date: DateTime(2026, 8, 21), maxPrice: 5000)),
    act: (cubit) => cubit.applyWideningSuggestion(
      const WideningSuggestion(code: 'RELAX_DATE', message: 'Élargir', suggestedQuery: {}),
    ),
    expect: () => [
      isA<IntercitySearchState>().having((s) => s.filters.date, 'date', isNull),
      isA<IntercitySearchState>().having((s) => s.status, 'status', IntercitySearchStatus.loading),
      isA<IntercitySearchState>().having((s) => s.status, 'status', IntercitySearchStatus.success),
    ],
  );

  blocTest<IntercitySearchCubit, IntercitySearchState>(
    'resetAll restores initial state',
    build: () => IntercitySearchCubit(repository),
    seed: () => IntercitySearchState(
      status: IntercitySearchStatus.success,
      filters: const SearchFilters(departureCity: 'Yaoundé', seats: 3),
    ),
    act: (cubit) {
      cubit.clearFilters();
      cubit.resetAll();
    },
    expect: () => [
      isA<IntercitySearchState>().having((s) => s.filters.seats, 'seats', 3),
      const IntercitySearchState(),
    ],
  );
}
