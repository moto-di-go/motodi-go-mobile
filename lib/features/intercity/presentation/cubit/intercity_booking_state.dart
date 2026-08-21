part of 'intercity_booking_cubit.dart';

enum IntercityDetailStatus { initial, loading, success, failure }

enum IntercitySubscribeStatus { initial, submitting, success, failure }

enum IntercityBookingsStatus { initial, loading, success, failure }

enum IntercityItineraryStatus { idle, loading, ready, failure }

class IntercityItinerary extends Equatable {
  final String polylineWkt;
  final LatLng origin;
  final LatLng destination;

  const IntercityItinerary({
    required this.polylineWkt,
    required this.origin,
    required this.destination,
  });

  @override
  List<Object?> get props => [polylineWkt, origin, destination];
}

class IntercityBookingState extends Equatable {
  final IntercityDetailStatus detailStatus;
  final IntercityAnnouncement? announcement;
  final String? detailErrorMessage;

  final IntercitySubscribeStatus subscribeStatus;
  final IntercityBooking? createdBooking;
  final String? subscribeErrorMessage;
  final String? subscribeErrorCode;

  final IntercityBookingsStatus myBookingsStatus;
  final List<IntercityBooking> myBookings;
  final Map<String, IntercityAnnouncement> myBookingAnnouncements;
  final int myBookingsPage;
  final bool myBookingsHasMore;
  final String? myBookingsErrorMessage;

  final IntercityBookingsStatus bookingStatus;
  final IntercityBooking? booking;
  final String? bookingErrorMessage;

  final IntercityItineraryStatus itineraryStatus;
  final IntercityItinerary? itinerary;

  const IntercityBookingState({
    this.detailStatus = IntercityDetailStatus.initial,
    this.announcement,
    this.detailErrorMessage,
    this.subscribeStatus = IntercitySubscribeStatus.initial,
    this.createdBooking,
    this.subscribeErrorMessage,
    this.subscribeErrorCode,
    this.myBookingsStatus = IntercityBookingsStatus.initial,
    this.myBookings = const [],
    this.myBookingAnnouncements = const {},
    this.myBookingsPage = 0,
    this.myBookingsHasMore = false,
    this.myBookingsErrorMessage,
    this.bookingStatus = IntercityBookingsStatus.initial,
    this.booking,
    this.bookingErrorMessage,
    this.itineraryStatus = IntercityItineraryStatus.idle,
    this.itinerary,
  });

  bool get isDetailLoading => detailStatus == IntercityDetailStatus.loading;
  bool get isSubscribing => subscribeStatus == IntercitySubscribeStatus.submitting;
  bool get isMyBookingsLoading => myBookingsStatus == IntercityBookingsStatus.loading;
  bool get isBookingLoading => bookingStatus == IntercityBookingsStatus.loading;

  IntercityBookingState copyWith({
    IntercityDetailStatus? detailStatus,
    IntercityAnnouncement? announcement,
    String? detailErrorMessage,
    IntercitySubscribeStatus? subscribeStatus,
    IntercityBooking? createdBooking,
    String? subscribeErrorMessage,
    String? subscribeErrorCode,
    IntercityBookingsStatus? myBookingsStatus,
    List<IntercityBooking>? myBookings,
    Map<String, IntercityAnnouncement>? myBookingAnnouncements,
    int? myBookingsPage,
    bool? myBookingsHasMore,
    String? myBookingsErrorMessage,
    IntercityBookingsStatus? bookingStatus,
    IntercityBooking? booking,
    String? bookingErrorMessage,
    IntercityItineraryStatus? itineraryStatus,
    IntercityItinerary? itinerary,
    bool clearItinerary = false,
  }) {
    return IntercityBookingState(
      detailStatus: detailStatus ?? this.detailStatus,
      announcement: announcement ?? this.announcement,
      detailErrorMessage: detailErrorMessage,
      subscribeStatus: subscribeStatus ?? this.subscribeStatus,
      createdBooking: createdBooking ?? this.createdBooking,
      subscribeErrorMessage: subscribeErrorMessage,
      subscribeErrorCode: subscribeErrorCode,
      myBookingsStatus: myBookingsStatus ?? this.myBookingsStatus,
      myBookings: myBookings ?? this.myBookings,
      myBookingAnnouncements: myBookingAnnouncements ?? this.myBookingAnnouncements,
      myBookingsPage: myBookingsPage ?? this.myBookingsPage,
      myBookingsHasMore: myBookingsHasMore ?? this.myBookingsHasMore,
      myBookingsErrorMessage: myBookingsErrorMessage,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      booking: booking ?? this.booking,
      bookingErrorMessage: bookingErrorMessage,
      itineraryStatus: itineraryStatus ?? this.itineraryStatus,
      itinerary: clearItinerary ? null : (itinerary ?? this.itinerary),
    );
  }

  @override
  List<Object?> get props => [
    detailStatus,
    announcement,
    detailErrorMessage,
    subscribeStatus,
    createdBooking,
    subscribeErrorMessage,
    subscribeErrorCode,
    myBookingsStatus,
    myBookings,
    myBookingAnnouncements,
    myBookingsPage,
    myBookingsHasMore,
    myBookingsErrorMessage,
    bookingStatus,
    booking,
    bookingErrorMessage,
    itineraryStatus,
    itinerary,
  ];
}
