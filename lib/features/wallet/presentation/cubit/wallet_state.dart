part of 'wallet_cubit.dart';

enum WalletViewStatus { initial, loading, loadingMore, success, failure }

class WalletState extends Equatable {
  final WalletViewStatus status;
  final WalletAccount? wallet;
  final List<LedgerEntry> entries;
  final int page;
  final bool hasMore;
  final String? errorMessage;
  final DateTime? lastRefreshedAt;

  const WalletState({
    this.status = WalletViewStatus.initial,
    this.wallet,
    this.entries = const [],
    this.page = 0,
    this.hasMore = false,
    this.errorMessage,
    this.lastRefreshedAt,
  });

  bool get isLoading => status == WalletViewStatus.loading || status == WalletViewStatus.initial;

  bool get isFrozen => wallet?.isFrozen == true;

  WalletState copyWith({
    WalletViewStatus? status,
    WalletAccount? wallet,
    List<LedgerEntry>? entries,
    int? page,
    bool? hasMore,
    String? errorMessage,
    DateTime? lastRefreshedAt,
  }) {
    return WalletState(
      status: status ?? this.status,
      wallet: wallet ?? this.wallet,
      entries: entries ?? this.entries,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      lastRefreshedAt: lastRefreshedAt ?? this.lastRefreshedAt,
    );
  }

  @override
  List<Object?> get props => [
    status,
    wallet,
    entries,
    page,
    hasMore,
    errorMessage,
    lastRefreshedAt,
  ];
}
