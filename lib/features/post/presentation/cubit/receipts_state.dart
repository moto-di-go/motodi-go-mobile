part of 'receipts_cubit.dart';

enum ReceiptsViewStatus { initial, loading, loadingMore, success, failure }

class ReceiptsState extends Equatable {
  final ReceiptsViewStatus status;
  final List<PostReceipt> receipts;
  final int page;
  final bool hasMore;
  final String? errorMessage;

  const ReceiptsState({
    this.status = ReceiptsViewStatus.initial,
    this.receipts = const [],
    this.page = 0,
    this.hasMore = false,
    this.errorMessage,
  });

  bool get isLoading => status == ReceiptsViewStatus.loading || status == ReceiptsViewStatus.initial;

  ReceiptsState copyWith({
    ReceiptsViewStatus? status,
    List<PostReceipt>? receipts,
    int? page,
    bool? hasMore,
    String? errorMessage,
    bool clearItems = false,
  }) {
    return ReceiptsState(
      status: status ?? this.status,
      receipts: clearItems ? const [] : (receipts ?? this.receipts),
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, receipts, page, hasMore, errorMessage];
}
