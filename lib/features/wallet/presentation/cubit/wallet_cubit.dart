import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/wallet/domain/entities/wallet.dart';
import 'package:motodi_go_mobile/features/wallet/domain/repositories/wallet_repository.dart';

part 'wallet_state.dart';

@injectable
class WalletCubit extends Cubit<WalletState> {
  final WalletRepository _repository;
  static const _pageSize = 20;

  WalletCubit(this._repository) : super(const WalletState());

  Future<void> load() async {
    emit(state.copyWith(status: WalletViewStatus.loading, errorMessage: null));
    final walletResult = await _repository.getWallet();
    final ledgerResult = await _repository.getLedger(page: 0, size: _pageSize);

    String? error;
    WalletAccount? wallet;
    List<LedgerEntry> entries = const [];
    var page = 0;
    var hasMore = false;

    walletResult.fold((failure) => error = failure.message, (value) => wallet = value);
    ledgerResult.fold((failure) => error ??= failure.message, (value) {
      entries = value.entries;
      page = value.page;
      hasMore = value.hasMore;
    });

    if (wallet == null) {
      emit(
        state.copyWith(
          status: WalletViewStatus.failure,
          errorMessage: error ?? 'Chargement du portefeuille impossible.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: WalletViewStatus.success,
        wallet: wallet,
        entries: entries,
        page: page,
        hasMore: hasMore,
        errorMessage: error,
        lastRefreshedAt: DateTime.now(),
      ),
    );
  }

  Future<void> refresh() => load();

  Future<void> loadMore() async {
    if (!state.hasMore || state.status == WalletViewStatus.loadingMore) return;
    emit(state.copyWith(status: WalletViewStatus.loadingMore));
    final nextPage = state.page + 1;
    final result = await _repository.getLedger(page: nextPage, size: _pageSize);
    result.fold(
      (failure) =>
          emit(state.copyWith(status: WalletViewStatus.success, errorMessage: failure.message)),
      (page) => emit(
        state.copyWith(
          status: WalletViewStatus.success,
          entries: [...state.entries, ...page.entries],
          page: page.page,
          hasMore: page.hasMore,
        ),
      ),
    );
  }
}
