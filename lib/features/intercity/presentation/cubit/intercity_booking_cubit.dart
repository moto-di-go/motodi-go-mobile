import 'package:chopper/chopper.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_announcement.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_booking.dart';
import 'package:motodi_go_mobile/features/intercity/domain/repositories/intercity_repository.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_models.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_remote_datasource.dart';
import 'package:motodi_go_mobile/features/urban/presentation/wkt_parser.dart';

part 'intercity_booking_state.dart';

// Role : Pilote le detail d'une annonce, la souscription (creation de reservation)
// et la consultation des reservations du passager.
@injectable
class IntercityBookingCubit extends Cubit<IntercityBookingState> {
  final IntercityRepository _repository;
  final UrbanRemoteDataSource _urbanRemote;
  static const _pageSize = 20;

  IntercityBookingCubit(this._repository, ChopperClient client)
    : _urbanRemote = UrbanRemoteDataSource(client),
      super(const IntercityBookingState());

  Future<void> loadDetail(String announcementId) async {
    emit(
      state.copyWith(
        detailStatus: IntercityDetailStatus.loading,
        detailErrorMessage: null,
        itineraryStatus: IntercityItineraryStatus.idle,
        clearItinerary: true,
      ),
    );
    final result = await _repository.getAnnouncement(announcementId);
    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            detailStatus: IntercityDetailStatus.failure,
            detailErrorMessage: failure.message,
          ),
        );
      },
      (announcement) async {
        emit(
          state.copyWith(detailStatus: IntercityDetailStatus.success, announcement: announcement),
        );
        await _loadItinerary(announcement);
      },
    );
  }

  Future<void> _loadItinerary(IntercityAnnouncement announcement) async {
    emit(state.copyWith(itineraryStatus: IntercityItineraryStatus.loading, clearItinerary: true));
    try {
      final originPlaces = await _urbanRemote.geocode(announcement.departureCity, kind: 'CITY');
      final destPlaces = await _urbanRemote.geocode(announcement.destinationCity, kind: 'CITY');
      if (isClosed) return;
      final origin = originPlaces == null || originPlaces.isEmpty ? null : originPlaces.first;
      final dest = destPlaces == null || destPlaces.isEmpty ? null : destPlaces.first;
      if (origin == null || dest == null) {
        emit(state.copyWith(itineraryStatus: IntercityItineraryStatus.failure));
        return;
      }
      final preview = await _urbanRemote.previewRoute(
        originLat: origin.point.latitude,
        originLon: origin.point.longitude,
        destinationLat: dest.point.latitude,
        destinationLon: dest.point.longitude,
        costing: 'auto',
      );
      if (isClosed) return;
      if (!_isRoadItinerary(preview)) {
        emit(state.copyWith(itineraryStatus: IntercityItineraryStatus.failure));
        return;
      }
      emit(
        state.copyWith(
          itineraryStatus: IntercityItineraryStatus.ready,
          itinerary: IntercityItinerary(
            polylineWkt: preview!.polyline,
            origin: origin.point,
            destination: dest.point,
          ),
        ),
      );
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(itineraryStatus: IntercityItineraryStatus.failure));
      }
    }
  }

  static bool _isRoadItinerary(RoutePreview? preview) {
    if (preview == null || preview.polyline.trim().isEmpty) {
      return false;
    }
    if (preview.engine.toUpperCase() == 'DIRECT') {
      return false;
    }
    return parseWktLine(preview.polyline).length >= 3;
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
      state.copyWith(
        myBookingsStatus: IntercityBookingsStatus.loading,
        myBookingsErrorMessage: null,
      ),
    );
    final result = await _repository.listMyBookings(page: nextPage, size: _pageSize);
    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            myBookingsStatus: IntercityBookingsStatus.failure,
            myBookingsErrorMessage: failure.message,
          ),
        );
      },
      (page) async {
        final bookings = loadMore ? [...state.myBookings, ...page.items] : page.items;
        emit(
          state.copyWith(
            myBookingsStatus: IntercityBookingsStatus.success,
            myBookings: bookings,
            myBookingsPage: page.page,
            myBookingsHasMore: page.hasMore,
          ),
        );
        await _enrichBookingAnnouncements(page.items);
      },
    );
  }

  Future<void> _enrichBookingAnnouncements(List<IntercityBooking> bookings) async {
    final missingIds = bookings
        .map((b) => b.announcementId)
        .where((id) => id.isNotEmpty && !state.myBookingAnnouncements.containsKey(id))
        .toSet();
    if (missingIds.isEmpty) return;
    final merged = Map<String, IntercityAnnouncement>.from(state.myBookingAnnouncements);
    await Future.wait(
      missingIds.map((id) async {
        final result = await _repository.getAnnouncement(id);
        result.fold((_) {}, (announcement) => merged[id] = announcement);
      }),
    );
    if (!isClosed) {
      emit(state.copyWith(myBookingAnnouncements: merged));
    }
  }

  Future<void> loadBooking(String bookingId) async {
    emit(state.copyWith(bookingStatus: IntercityBookingsStatus.loading, bookingErrorMessage: null));
    final result = await _repository.getBooking(bookingId);
    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            bookingStatus: IntercityBookingsStatus.failure,
            bookingErrorMessage: failure.message,
          ),
        );
      },
      (booking) async {
        emit(state.copyWith(bookingStatus: IntercityBookingsStatus.success, booking: booking));
        final announcementResult = await _repository.getAnnouncement(booking.announcementId);
        await announcementResult.fold((_) async {}, (announcement) async {
          emit(state.copyWith(announcement: announcement));
          await _loadItinerary(announcement);
        });
      },
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
