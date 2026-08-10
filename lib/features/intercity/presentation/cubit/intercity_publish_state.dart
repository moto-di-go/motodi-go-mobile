part of 'intercity_publish_cubit.dart';

enum IntercityEligibilityStatus { initial, checking, eligible, ineligible, failure }

enum IntercityVehiclesStatus { initial, loading, success, failure }

enum IntercityCreateStatus { initial, submitting, success, failure }

enum IntercityMineStatus { initial, loading, success, failure }

enum IntercityIncomingStatus { initial, loading, success, failure }

class IntercityPublishState extends Equatable {
  final IntercityEligibilityStatus eligibilityStatus;
  final String? eligibilityReason;

  final IntercityVehiclesStatus vehiclesStatus;
  final List<IntercityVehicle> vehicles;
  final String? vehiclesErrorMessage;

  final IntercityCreateStatus createStatus;
  final IntercityAnnouncement? createdAnnouncement;
  final String? createErrorMessage;

  final IntercityMineStatus mineStatus;
  final List<IntercityAnnouncement> myAnnouncements;
  final int minePage;
  final bool mineHasMore;
  final String? mineErrorMessage;

  final IntercityIncomingStatus incomingStatus;
  final List<IntercityBooking> incomingBookings;
  final String? currentAnnouncementId;
  final String? incomingErrorMessage;
  final Set<String> processingBookingIds;

  const IntercityPublishState({
    this.eligibilityStatus = IntercityEligibilityStatus.initial,
    this.eligibilityReason,
    this.vehiclesStatus = IntercityVehiclesStatus.initial,
    this.vehicles = const [],
    this.vehiclesErrorMessage,
    this.createStatus = IntercityCreateStatus.initial,
    this.createdAnnouncement,
    this.createErrorMessage,
    this.mineStatus = IntercityMineStatus.initial,
    this.myAnnouncements = const [],
    this.minePage = 0,
    this.mineHasMore = false,
    this.mineErrorMessage,
    this.incomingStatus = IntercityIncomingStatus.initial,
    this.incomingBookings = const [],
    this.currentAnnouncementId,
    this.incomingErrorMessage,
    this.processingBookingIds = const {},
  });

  bool get isEligible => eligibilityStatus == IntercityEligibilityStatus.eligible;
  bool get isCheckingEligibility => eligibilityStatus == IntercityEligibilityStatus.checking;
  bool get isLoadingVehicles => vehiclesStatus == IntercityVehiclesStatus.loading;
  bool get isCreating => createStatus == IntercityCreateStatus.submitting;
  bool get isLoadingMine => mineStatus == IntercityMineStatus.loading;
  bool get isLoadingIncoming => incomingStatus == IntercityIncomingStatus.loading;

  IntercityPublishState copyWith({
    IntercityEligibilityStatus? eligibilityStatus,
    String? eligibilityReason,
    IntercityVehiclesStatus? vehiclesStatus,
    List<IntercityVehicle>? vehicles,
    String? vehiclesErrorMessage,
    IntercityCreateStatus? createStatus,
    IntercityAnnouncement? createdAnnouncement,
    String? createErrorMessage,
    IntercityMineStatus? mineStatus,
    List<IntercityAnnouncement>? myAnnouncements,
    int? minePage,
    bool? mineHasMore,
    String? mineErrorMessage,
    IntercityIncomingStatus? incomingStatus,
    List<IntercityBooking>? incomingBookings,
    String? currentAnnouncementId,
    String? incomingErrorMessage,
    Set<String>? processingBookingIds,
  }) {
    return IntercityPublishState(
      eligibilityStatus: eligibilityStatus ?? this.eligibilityStatus,
      eligibilityReason: eligibilityReason,
      vehiclesStatus: vehiclesStatus ?? this.vehiclesStatus,
      vehicles: vehicles ?? this.vehicles,
      vehiclesErrorMessage: vehiclesErrorMessage,
      createStatus: createStatus ?? this.createStatus,
      createdAnnouncement: createdAnnouncement ?? this.createdAnnouncement,
      createErrorMessage: createErrorMessage,
      mineStatus: mineStatus ?? this.mineStatus,
      myAnnouncements: myAnnouncements ?? this.myAnnouncements,
      minePage: minePage ?? this.minePage,
      mineHasMore: mineHasMore ?? this.mineHasMore,
      mineErrorMessage: mineErrorMessage,
      incomingStatus: incomingStatus ?? this.incomingStatus,
      incomingBookings: incomingBookings ?? this.incomingBookings,
      currentAnnouncementId: currentAnnouncementId ?? this.currentAnnouncementId,
      incomingErrorMessage: incomingErrorMessage,
      processingBookingIds: processingBookingIds ?? this.processingBookingIds,
    );
  }

  @override
  List<Object?> get props => [
    eligibilityStatus,
    eligibilityReason,
    vehiclesStatus,
    vehicles,
    vehiclesErrorMessage,
    createStatus,
    createdAnnouncement,
    createErrorMessage,
    mineStatus,
    myAnnouncements,
    minePage,
    mineHasMore,
    mineErrorMessage,
    incomingStatus,
    incomingBookings,
    currentAnnouncementId,
    incomingErrorMessage,
    processingBookingIds,
  ];
}
