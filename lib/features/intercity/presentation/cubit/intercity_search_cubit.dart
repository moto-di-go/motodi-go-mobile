import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_announcement.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/search_filters.dart';
import 'package:motodi_go_mobile/features/intercity/domain/repositories/intercity_repository.dart';

part 'intercity_search_state.dart';

// Role : Pilote la recherche de trajets intercity et conserve les filtres en session.
@injectable
class IntercitySearchCubit extends Cubit<IntercitySearchState> {
  final IntercityRepository _repository;
  static const _pageSize = 20;

  IntercitySearchCubit(this._repository) : super(const IntercitySearchState());

  void updateFilters(SearchFilters Function(SearchFilters current) update) {
    emit(state.copyWith(filters: update(state.filters)));
  }

  void setDepartureCity(String? city) {
    final trimmed = city?.trim();
    emit(
      state.copyWith(
        filters: state.filters.copyWith(
          departureCity: trimmed,
          clearDepartureCity: trimmed == null || trimmed.isEmpty,
        ),
      ),
    );
  }

  void setDestinationCity(String? city) {
    final trimmed = city?.trim();
    emit(
      state.copyWith(
        filters: state.filters.copyWith(
          destinationCity: trimmed,
          clearDestinationCity: trimmed == null || trimmed.isEmpty,
        ),
      ),
    );
  }

  void setSeats(int seats) {
    if (seats < 1) return;
    emit(state.copyWith(filters: state.filters.copyWith(seats: seats)));
  }

  void toggleMap() {
    emit(state.copyWith(showMap: !state.showMap));
  }

  void clearFilters() {
    emit(state.copyWith(filters: state.filters.clearAdvancedFilters()));
  }

  void resetAll() {
    emit(const IntercitySearchState());
  }

  Future<void> search() async {
    emit(
      state.copyWith(
        status: IntercitySearchStatus.loading,
        errorMessage: null,
        errorCode: null,
        page: 0,
      ),
    );
    final result = await _repository.searchAnnouncements(state.filters, page: 0, size: _pageSize);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: IntercitySearchStatus.failure,
          errorMessage: failure.message,
          errorCode: failure.code,
          results: [],
        ),
      ),
      (page) => emit(
        state.copyWith(
          status: IntercitySearchStatus.success,
          results: page.items,
          wideningSuggestions: page.wideningSuggestions,
          page: page.page,
          hasMore: page.hasMore,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;
    emit(state.copyWith(status: IntercitySearchStatus.loadingMore));
    final nextPage = state.page + 1;
    final result = await _repository.searchAnnouncements(state.filters, page: nextPage, size: _pageSize);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: IntercitySearchStatus.success,
          errorMessage: failure.message,
          errorCode: failure.code,
        ),
      ),
      (page) => emit(
        state.copyWith(
          status: IntercitySearchStatus.success,
          results: [...state.results, ...page.items],
          page: page.page,
          hasMore: page.hasMore,
        ),
      ),
    );
  }

  Future<void> applyWideningSuggestion(WideningSuggestion suggestion) async {
    var filters = state.filters.applyingWidening(suggestion.suggestedQuery);
    switch (suggestion.code) {
      case 'RELAX_DATE':
        filters = filters.copyWith(clearDate: true);
      case 'DROP_PT_RAMASSAGE':
        filters = filters.copyWith(clearPtRamassage: true);
      case 'DROP_TIME_RANGE':
        filters = filters.copyWith(clearTimeSlot: true);
      case 'RAISE_MAX_PRICE':
        final raised = suggestion.suggestedQuery['maxPrice'];
        if (raised is num) {
          filters = filters.copyWith(maxPrice: raised.toDouble());
        } else if (filters.maxPrice != null) {
          filters = filters.copyWith(maxPrice: (filters.maxPrice! * 1.2).ceilToDouble());
        }
      case 'INCLUDE_FULL':
        filters = filters.copyWith(onlyAvailable: false);
    }
    emit(state.copyWith(filters: filters));
    await search();
  }
}
