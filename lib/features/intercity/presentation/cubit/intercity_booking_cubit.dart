import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_announcement.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_booking.dart';
import 'package:motodi_go_mobile/features/intercity/domain/repositories/intercity_repository.dart';

part 'intercity_booking_state.dart';

// Role : Pilote le detail d'une annonce, la souscription (creation de reservation)
// et la consultation des reservations du passager.
@injectable
class IntercityBookingCubit extends Cubit<IntercityBookingState> {
  final IntercityRepository _repository;
  static const _pageSize = 20;

  IntercityBookingCubit(this._repository) : super(const IntercityBookingState());

  Future<void> loadDetail(String announcementId) async {
    emit(state.copyWith(detailStatus: IntercityDetailStatus.loading, detailErrorMessage: null));
    final result = await _repository.getAnnouncement(announcementId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          detailStatus: IntercityDetailStatus.failure,
          detailErrorMessage: failure.message,
        ),
      ),
      (announcement) => emit(
        state.copyWith(detailStatus: IntercityDetailStatus.success, announcement: announcement),
      ),
    );
  }

  Future<void> subscribe({
    required String announcementId,
    required int seatsRequested,
    required String contactPhone,
  }) async {
    emit(
      state.copyWith(
        subscribeStatus: IntercitySubscribeStatus.submitting,
        subscribeErrorMessage: null,
        subscribeErrorCode: null,
      ),
    );
    final result = await _repository.createBooking(
      announcementId: announcementId,
      seatsRequested: seatsRequested,
      contactPhone: contactPhone,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          subscribeStatus: IntercitySubscribeStatus.failure,
          subscribeErrorMessage: failure.message,
          subscribeErrorCode: failure.code,
        ),
      ),
      (booking) => emit(
        state.copyWith(subscribeStatus: IntercitySubscribeStatus.success, createdBooking: booking),
      ),
    );
  }

  void resetSubscribeStatus() {
    emit(state.copyWith(subscribeStatus: IntercitySubscribeStatus.initial));
  }

  Future<void> loadMyBookings({bool loadMore = false}) async {
    if (loadMore && (!state.myBookingsHasMore || state.isMyBookingsLoading)) return;
    final nextPage = loadMore ? state.myBookingsPage + 1 : 0;
    emit(
      state.copyWith(myBookingsStatus: IntercityBookingsStatus.loading, myBookingsErrorMessage: null),
    );
    final result = await _repository.listMyBookings(page: nextPage, size: _pageSize);
    result.fold(
      (failure) => emit(
        state.copyWith(
          myBookingsStatus: IntercityBookingsStatus.failure,
          myBookingsErrorMessage: failure.message,
        ),
      ),
      (page) => emit(
        state.copyWith(
          myBookingsStatus: IntercityBookingsStatus.success,
          myBookings: loadMore ? [...state.myBookings, ...page.items] : page.items,
          myBookingsPage: page.page,
          myBookingsHasMore: page.hasMore,
        ),
      ),
    );
  }

  Future<void> loadBooking(String bookingId) async {
    emit(state.copyWith(bookingStatus: IntercityBookingsStatus.loading, bookingErrorMessage: null));
    final result = await _repository.getBooking(bookingId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          bookingStatus: IntercityBookingsStatus.failure,
          bookingErrorMessage: failure.message,
        ),
      ),
      (booking) =>
          emit(state.copyWith(bookingStatus: IntercityBookingsStatus.success, booking: booking)),
    );
  }

  Future<bool> cancelBooking(String bookingId, String reason) async {
    final result = await _repository.cancelBooking(bookingId, reason);
    return result.fold((failure) => false, (booking) {
      emit(state.copyWith(bookingStatus: IntercityBookingsStatus.success, booking: booking));
      return true;
    });
  }
}
