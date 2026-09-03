part of 'rating_cubit.dart';

enum RatingViewStatus { initial, loading, ready, submitting, success, failure, impossible }

enum RatingImpossibleReason { notCompleted, alreadyRated, forbidden, notFound, noRatee }

class RatingState extends Equatable {
  final RatingViewStatus status;
  final String? tripId;
  final Trip? trip;
  final String? ratedProfileId;
  final int stars;
  final String comment;
  final Set<RatingTag> selectedTags;
  final List<TripRating> existingRatings;
  final TripRating? submittedRating;
  final RatingImpossibleReason? impossibleReason;
  final String? errorMessage;

  const RatingState({
    this.status = RatingViewStatus.initial,
    this.tripId,
    this.trip,
    this.ratedProfileId,
    this.stars = 0,
    this.comment = '',
    this.selectedTags = const {},
    this.existingRatings = const [],
    this.submittedRating,
    this.impossibleReason,
    this.errorMessage,
  });

  bool get canSubmit => stars >= 1 && status == RatingViewStatus.ready;

  RatingState copyWith({
    RatingViewStatus? status,
    String? tripId,
    Trip? trip,
    String? ratedProfileId,
    int? stars,
    String? comment,
    Set<RatingTag>? selectedTags,
    List<TripRating>? existingRatings,
    TripRating? submittedRating,
    RatingImpossibleReason? impossibleReason,
    String? errorMessage,
  }) {
    return RatingState(
      status: status ?? this.status,
      tripId: tripId ?? this.tripId,
      trip: trip ?? this.trip,
      ratedProfileId: ratedProfileId ?? this.ratedProfileId,
      stars: stars ?? this.stars,
      comment: comment ?? this.comment,
      selectedTags: selectedTags ?? this.selectedTags,
      existingRatings: existingRatings ?? this.existingRatings,
      submittedRating: submittedRating ?? this.submittedRating,
      impossibleReason: impossibleReason ?? this.impossibleReason,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    tripId,
    trip,
    ratedProfileId,
    stars,
    comment,
    selectedTags,
    existingRatings,
    submittedRating,
    impossibleReason,
    errorMessage,
  ];
}
