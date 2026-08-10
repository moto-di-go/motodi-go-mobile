part of 'intercity_search_cubit.dart';

enum IntercitySearchStatus { initial, loading, loadingMore, success, failure }

class IntercitySearchState extends Equatable {
  final IntercitySearchStatus status;
  final SearchFilters filters;
  final List<IntercityAnnouncement> results;
  final List<WideningSuggestion> wideningSuggestions;
  final int page;
  final bool hasMore;
  final String? errorMessage;
  final String? errorCode;
  final bool showMap;

  const IntercitySearchState({
    this.status = IntercitySearchStatus.initial,
    this.filters = const SearchFilters(),
    this.results = const [],
    this.wideningSuggestions = const [],
    this.page = 0,
    this.hasMore = false,
    this.errorMessage,
    this.errorCode,
    this.showMap = false,
  });

  bool get isLoading => status == IntercitySearchStatus.loading;
  bool get isLoadingMore => status == IntercitySearchStatus.loadingMore;
  bool get isEmptyResult => status == IntercitySearchStatus.success && results.isEmpty;

  IntercitySearchState copyWith({
    IntercitySearchStatus? status,
    SearchFilters? filters,
    List<IntercityAnnouncement>? results,
    List<WideningSuggestion>? wideningSuggestions,
    int? page,
    bool? hasMore,
    String? errorMessage,
    String? errorCode,
    bool? showMap,
  }) {
    return IntercitySearchState(
      status: status ?? this.status,
      filters: filters ?? this.filters,
      results: results ?? this.results,
      wideningSuggestions: wideningSuggestions ?? this.wideningSuggestions,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      errorCode: errorCode,
      showMap: showMap ?? this.showMap,
    );
  }

  @override
  List<Object?> get props => [
    status,
    filters,
    results,
    wideningSuggestions,
    page,
    hasMore,
    errorMessage,
    errorCode,
    showMap,
  ];
}
