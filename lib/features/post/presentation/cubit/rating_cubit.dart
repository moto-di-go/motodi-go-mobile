import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/post/domain/entities/post_entities.dart';
import 'package:motodi_go_mobile/features/post/domain/repositories/post_repository.dart';
import 'package:motodi_go_mobile/features/trips/domain/entities/trip.dart';
import 'package:motodi_go_mobile/features/trips/domain/repositories/trip_repository.dart';

part 'rating_state.dart';

@injectable
class RatingCubit extends Cubit<RatingState> {
  final PostRepository _postRepository;
  final TripRepository _tripRepository;

  RatingCubit(this._postRepository, this._tripRepository) : super(const RatingState());

  Future<void> load(String tripId, {String? preferredRatedProfileId}) async {
    emit(state.copyWith(status: RatingViewStatus.loading, tripId: tripId, errorMessage: null));

    final tripResult = await _tripRepository.getTrip(tripId);
    Trip? trip;
    String? tripError;
    tripResult.fold((f) => tripError = f.message, (t) => trip = t);

    if (trip == null) {
      emit(
        state.copyWith(
          status: RatingViewStatus.impossible,
          impossibleReason: RatingImpossibleReason.notFound,
          errorMessage: tripError ?? 'Trajet introuvable.',
        ),
      );
      return;
    }

    if (trip!.status != TripStatus.completed) {
      emit(
        state.copyWith(
          status: RatingViewStatus.impossible,
          trip: trip,
          impossibleReason: RatingImpossibleReason.notCompleted,
          errorMessage: 'Le trajet doit être terminé pour noter.',
        ),
      );
      return;
    }

    final ratingsResult = await _postRepository.getTripRatings(tripId);
    List<TripRating> existing = const [];
    String? ratingsError;
    ratingsResult.fold((f) => ratingsError = f.message, (list) => existing = list);

    if (ratingsError != null && existing.isEmpty) {
      // Soft-fail: allow rating attempt even if list fails (except network/auth).
      if (ratingsError!.contains('connexion') || ratingsError!.toLowerCase().contains('session')) {
        emit(
          state.copyWith(
            status: RatingViewStatus.failure,
            trip: trip,
            errorMessage: ratingsError,
          ),
        );
        return;
      }
    }

    if (existing.isNotEmpty) {
      emit(
        state.copyWith(
          status: RatingViewStatus.impossible,
          trip: trip,
          existingRatings: existing,
          impossibleReason: RatingImpossibleReason.alreadyRated,
          errorMessage: 'Vous avez déjà noté ce trajet.',
        ),
      );
      return;
    }

    final ratedProfileId =
        preferredRatedProfileId ??
        trip!.driverProfileId ??
        trip!.transporterProfileId ??
        trip!.passengerProfileId;

    if (ratedProfileId == null || ratedProfileId.isEmpty) {
      emit(
        state.copyWith(
          status: RatingViewStatus.impossible,
          trip: trip,
          impossibleReason: RatingImpossibleReason.noRatee,
          errorMessage: 'Impossible d’identifier le profil à noter.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: RatingViewStatus.ready,
        trip: trip,
        ratedProfileId: ratedProfileId,
        stars: 0,
        selectedTags: const {},
        comment: '',
        errorMessage: null,
      ),
    );
  }

  void setStars(int stars) {
    if (stars < 1 || stars > 5) return;
    emit(state.copyWith(stars: stars, errorMessage: null));
  }

  void setComment(String comment) {
    emit(state.copyWith(comment: comment));
  }

  void toggleTag(RatingTag tag) {
    final next = Set<RatingTag>.from(state.selectedTags);
    if (next.contains(tag)) {
      next.remove(tag);
    } else {
      next.add(tag);
    }
    emit(state.copyWith(selectedTags: next));
  }

  Future<void> submit() async {
    if (state.stars < 1) {
      emit(state.copyWith(errorMessage: 'Choisissez une note de 1 à 5 étoiles.'));
      return;
    }
    final tripId = state.tripId;
    final ratedProfileId = state.ratedProfileId;
    if (tripId == null || ratedProfileId == null) return;

    emit(state.copyWith(status: RatingViewStatus.submitting, errorMessage: null));
    final result = await _postRepository.submitRating(
      tripId: tripId,
      ratedProfileId: ratedProfileId,
      stars: state.stars,
      comment: state.comment.trim().isEmpty ? null : state.comment.trim(),
      tags: state.selectedTags.toList(),
    );

    result.fold(
      (failure) {
        if (failure.code == 'NETWORK_OFFLINE') {
          emit(
            state.copyWith(
              status: RatingViewStatus.ready,
              errorMessage: 'Connexion requise pour envoyer la note. Réessayez en ligne.',
            ),
          );
          return;
        }
        if (failure.code == 'RATING_ALREADY_EXISTS') {
          emit(
            state.copyWith(
              status: RatingViewStatus.impossible,
              impossibleReason: RatingImpossibleReason.alreadyRated,
              errorMessage: failure.message,
            ),
          );
          return;
        }
        if (failure.code == 'TRIP_NOT_COMPLETED') {
          emit(
            state.copyWith(
              status: RatingViewStatus.impossible,
              impossibleReason: RatingImpossibleReason.notCompleted,
              errorMessage: failure.message,
            ),
          );
          return;
        }
        if (failure.code == 'RATING_FORBIDDEN') {
          emit(
            state.copyWith(
              status: RatingViewStatus.impossible,
              impossibleReason: RatingImpossibleReason.forbidden,
              errorMessage: failure.message,
            ),
          );
          return;
        }
        emit(state.copyWith(status: RatingViewStatus.ready, errorMessage: failure.message));
      },
      (rating) => emit(
        state.copyWith(
          status: RatingViewStatus.success,
          submittedRating: rating,
          errorMessage: null,
        ),
      ),
    );
  }
}
