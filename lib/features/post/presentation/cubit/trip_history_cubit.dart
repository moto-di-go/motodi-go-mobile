import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/post/domain/entities/post_entities.dart';
import 'package:motodi_go_mobile/features/post/domain/repositories/post_repository.dart';

part 'trip_history_state.dart';

@injectable
class TripHistoryCubit extends Cubit<TripHistoryState> {
  final PostRepository _repository;
  static const _pageSize = 20;

  TripHistoryCubit(this._repository) : super(const TripHistoryState());

  Future<void> load({TripHistoryTab? tab}) async {
    final nextTab = tab ?? state.tab;
    emit(
      state.copyWith(
        status: TripHistoryViewStatus.loading,
        tab: nextTab,
        errorMessage: null,
        clearItems: true,
      ),
    );
    await _fetch(page: 0, replace: true);
  }

  Future<void> refresh() => load(tab: state.tab);

  Future<void> setTab(TripHistoryTab tab) {
    if (tab == state.tab && state.items.isNotEmpty) return Future.value();
    return load(tab: tab);
  }

  void setTripTypeFilter(String? tripType) {
    emit(state.copyWith(tripTypeFilter: tripType, clearTripType: tripType == null));
  }

  void setPaymentStatusFilter(String? paymentStatus) {
    emit(
      state.copyWith(
        paymentStatusFilter: paymentStatus,
        clearPaymentStatus: paymentStatus == null,
      ),
    );
  }

  Future<void> applyFilters({String? tripType, String? paymentStatus}) async {
    emit(
      state.copyWith(
        tripTypeFilter: tripType,
        paymentStatusFilter: paymentStatus,
        clearTripType: tripType == null,
        clearPaymentStatus: paymentStatus == null,
        status: TripHistoryViewStatus.loading,
        clearItems: true,
        errorMessage: null,
      ),
    );
    await _fetch(page: 0, replace: true);
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.status == TripHistoryViewStatus.loadingMore) return;
    emit(state.copyWith(status: TripHistoryViewStatus.loadingMore));
    await _fetch(page: state.page + 1, replace: false);
  }

  Future<void> _fetch({required int page, required bool replace}) async {
    final result = await _repository.getTripHistory(
      tab: state.tab,
      tripType: state.tripTypeFilter,
      paymentStatus: state.paymentStatusFilter,
      page: page,
      size: _pageSize,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TripHistoryViewStatus.failure,
          errorMessage: failure.message,
          items: replace ? const [] : state.items,
        ),
      ),
      (data) => emit(
        state.copyWith(
          status: TripHistoryViewStatus.success,
          items: replace ? data.items : [...state.items, ...data.items],
          page: data.page,
          hasMore: data.hasMore,
          errorMessage: null,
        ),
      ),
    );
  }
}
