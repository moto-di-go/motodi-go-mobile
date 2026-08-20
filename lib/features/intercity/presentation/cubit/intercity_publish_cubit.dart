import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_announcement.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_booking.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_vehicle.dart';
import 'package:motodi_go_mobile/features/intercity/domain/repositories/intercity_repository.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';
import 'package:motodi_go_mobile/features/profiles/domain/repositories/profile_repository.dart';

part 'intercity_publish_state.dart';

// Role : Pilote la publication d'annonces (eligibilite, vehicules, creation,
// mes annonces, reservations entrantes a confirmer/annuler).
@injectable
class IntercityPublishCubit extends Cubit<IntercityPublishState> {
  final IntercityRepository _repository;
  final ProfileRepository _profileRepository;
  static const _pageSize = 20;

  IntercityPublishCubit(this._repository, this._profileRepository)
    : super(const IntercityPublishState());

  // Verifie que le profil actif est un profil publisher (transporteur/mototaxi)
  // valide et qu'au moins un vehicule est disponible.
  Future<void> checkEligibility() async {
    emit(
      state.copyWith(
        eligibilityStatus: IntercityEligibilityStatus.checking,
        eligibilityReason: null,
      ),
    );
    final profileResult = await _profileRepository.currentProfile();
    final eligibility = await profileResult.fold<Future<(bool, String?)>>(
      (failure) async => (false, failure.message),
      (profile) async {
        if (profile.type != ProfileType.transporter && profile.type != ProfileType.mototaxi) {
          return (false, 'Seuls les profils transporteur ou mototaxi peuvent publier une annonce.');
        }
        if (!profile.isValidated) {
          return (false, 'Votre profil doit être validé avant de publier une annonce.');
        }
        final vehiclesResult = await _repository.listMyVehicles();
        return vehiclesResult.fold((failure) => (false, failure.message), (vehicles) {
          emit(state.copyWith(vehiclesStatus: IntercityVehiclesStatus.success, vehicles: vehicles));
          final usable = vehicles.where((vehicle) => vehicle.isUsable).toList();
          if (usable.isEmpty) {
            return (false, 'Ajoutez un véhicule validé à votre profil pour publier une annonce.');
          }
          return (true, null);
        });
      },
    );
    final (isEligible, reason) = eligibility;
    emit(
      state.copyWith(
        eligibilityStatus: isEligible
            ? IntercityEligibilityStatus.eligible
            : IntercityEligibilityStatus.ineligible,
        eligibilityReason: reason,
      ),
    );
  }

  Future<void> loadVehicles() async {
    emit(
      state.copyWith(vehiclesStatus: IntercityVehiclesStatus.loading, vehiclesErrorMessage: null),
    );
    final result = await _repository.listMyVehicles();
    result.fold(
      (failure) => emit(
        state.copyWith(
          vehiclesStatus: IntercityVehiclesStatus.failure,
          vehiclesErrorMessage: failure.message,
        ),
      ),
      (vehicles) =>
          emit(state.copyWith(vehiclesStatus: IntercityVehiclesStatus.success, vehicles: vehicles)),
    );
  }

  Future<void> createAnnouncement({
    required String departureCity,
    required String destinationCity,
    String? ptRamassage,
    double? departureLat,
    double? departureLon,
    double? destinationLat,
    double? destinationLon,
    required DateTime departureDate,
    required String departureTime,
    required double priceFcfa,
    required int totalSeats,
    required String vehicleId,
    String? instructions,
  }) async {
    emit(state.copyWith(createStatus: IntercityCreateStatus.submitting, createErrorMessage: null));
    final result = await _repository.createAnnouncement(
      departureCity: departureCity,
      destinationCity: destinationCity,
      ptRamassage: ptRamassage,
      departureLat: departureLat,
      departureLon: departureLon,
      destinationLat: destinationLat,
      destinationLon: destinationLon,
      departureDate: departureDate,
      departureTime: departureTime,
      priceFcfa: priceFcfa,
      totalSeats: totalSeats,
      vehicleId: vehicleId,
      instructions: instructions,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          createStatus: IntercityCreateStatus.failure,
          createErrorMessage: failure.message,
        ),
      ),
      (announcement) => emit(
        state.copyWith(
          createStatus: IntercityCreateStatus.success,
          createdAnnouncement: announcement,
        ),
      ),
    );
  }

  void resetCreateStatus() {
    emit(state.copyWith(createStatus: IntercityCreateStatus.initial));
  }

  Future<void> loadMyAnnouncements({bool loadMore = false}) async {
    if (loadMore && (!state.mineHasMore || state.isLoadingMine)) return;
    final nextPage = loadMore ? state.minePage + 1 : 0;
    emit(state.copyWith(mineStatus: IntercityMineStatus.loading, mineErrorMessage: null));
    final result = await _repository.listMyAnnouncements(page: nextPage, size: _pageSize);
    result.fold(
      (failure) => emit(
        state.copyWith(mineStatus: IntercityMineStatus.failure, mineErrorMessage: failure.message),
      ),
      (page) => emit(
        state.copyWith(
          mineStatus: IntercityMineStatus.success,
          myAnnouncements: loadMore ? [...state.myAnnouncements, ...page.items] : page.items,
          minePage: page.page,
          mineHasMore: page.hasMore,
        ),
      ),
    );
  }

  Future<bool> closeAnnouncement(String id) async {
    final result = await _repository.closeAnnouncement(id);
    return result.fold((failure) => false, (updated) {
      emit(
        state.copyWith(
          myAnnouncements: state.myAnnouncements
              .map((item) => item.id == updated.id ? updated : item)
              .toList(),
        ),
      );
      return true;
    });
  }

  Future<bool> cancelAnnouncement(String id) async {
    final result = await _repository.cancelAnnouncement(id);
    return result.fold((failure) => false, (updated) {
      emit(
        state.copyWith(
          myAnnouncements: state.myAnnouncements
              .map((item) => item.id == updated.id ? updated : item)
              .toList(),
        ),
      );
      return true;
    });
  }

  Future<void> loadIncomingBookings(String announcementId) async {
    emit(
      state.copyWith(
        incomingStatus: IntercityIncomingStatus.loading,
        incomingErrorMessage: null,
        currentAnnouncementId: announcementId,
      ),
    );
    final announcementResult = await _repository.getAnnouncement(announcementId);
    final bookingsResult = await _repository.listAnnouncementBookings(
      announcementId,
      page: 0,
      size: _pageSize,
    );

    announcementResult.fold(
      (failure) => emit(
        state.copyWith(
          incomingStatus: IntercityIncomingStatus.failure,
          incomingErrorMessage: failure.message,
        ),
      ),
      (announcement) {
        bookingsResult.fold(
          (failure) => emit(
            state.copyWith(
              incomingStatus: IntercityIncomingStatus.failure,
              incomingErrorMessage: failure.message,
              incomingAnnouncement: announcement,
            ),
          ),
          (page) => emit(
            state.copyWith(
              incomingStatus: IntercityIncomingStatus.success,
              incomingAnnouncement: announcement,
              incomingBookings: page.items,
            ),
          ),
        );
      },
    );
  }

  Future<bool> confirmIncomingBooking(String bookingId) async {
    emit(state.copyWith(processingBookingIds: {...state.processingBookingIds, bookingId}));
    final result = await _repository.confirmBooking(bookingId);
    final success = result.fold((failure) => false, (booking) {
      emit(
        state.copyWith(
          incomingBookings: state.incomingBookings
              .map((item) => item.id == booking.id ? booking : item)
              .toList(),
        ),
      );
      return true;
    });
    emit(state.copyWith(processingBookingIds: {...state.processingBookingIds}..remove(bookingId)));
    return success;
  }

  Future<bool> cancelIncomingBooking(String bookingId, String reason) async {
    emit(state.copyWith(processingBookingIds: {...state.processingBookingIds, bookingId}));
    final result = await _repository.cancelBooking(bookingId, reason);
    final success = result.fold((failure) => false, (booking) {
      emit(
        state.copyWith(
          incomingBookings: state.incomingBookings
              .map((item) => item.id == booking.id ? booking : item)
              .toList(),
        ),
      );
      return true;
    });
    emit(state.copyWith(processingBookingIds: {...state.processingBookingIds}..remove(bookingId)));
    return success;
  }
}
