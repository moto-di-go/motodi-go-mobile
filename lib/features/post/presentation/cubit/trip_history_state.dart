part of 'trip_history_cubit.dart';

enum TripHistoryViewStatus { initial, loading, loadingMore, success, failure }

class TripHistoryState extends Equatable {
  final TripHistoryViewStatus status;
  final TripHistoryTab tab;
  final List<TripHistoryItem> items;
  final int page;
  final bool hasMore;
  final String? tripTypeFilter;
  final String? paymentStatusFilter;
  final String? errorMessage;

  const TripHistoryState({
    this.status = TripHistoryViewStatus.initial,
    this.tab = TripHistoryTab.past,
    this.items = const [],
    this.page = 0,
    this.hasMore = false,
    this.tripTypeFilter,
    this.paymentStatusFilter,
    this.errorMessage,
  });

  bool get isLoading =>
      status == TripHistoryViewStatus.loading || status == TripHistoryViewStatus.initial;

  TripHistoryState copyWith({
    TripHistoryViewStatus? status,
    TripHistoryTab? tab,
    List<TripHistoryItem>? items,
    int? page,
    bool? hasMore,
    String? tripTypeFilter,
    String? paymentStatusFilter,
    String? errorMessage,
    bool clearItems = false,
    bool clearTripType = false,
    bool clearPaymentStatus = false,
  }) {
    return TripHistoryState(
      status: status ?? this.status,
      tab: tab ?? this.tab,
      items: clearItems ? const [] : (items ?? this.items),
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      tripTypeFilter: clearTripType ? null : (tripTypeFilter ?? this.tripTypeFilter),
      paymentStatusFilter: clearPaymentStatus
          ? null
          : (paymentStatusFilter ?? this.paymentStatusFilter),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    tab,
    items,
    page,
    hasMore,
    tripTypeFilter,
    paymentStatusFilter,
    errorMessage,
  ];
}
