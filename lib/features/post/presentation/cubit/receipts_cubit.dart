import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/post/domain/entities/post_entities.dart';
import 'package:motodi_go_mobile/features/post/domain/repositories/post_repository.dart';

part 'receipts_state.dart';

@injectable
class ReceiptsCubit extends Cubit<ReceiptsState> {
  final PostRepository _repository;
  static const _pageSize = 20;

  ReceiptsCubit(this._repository) : super(const ReceiptsState());

  Future<void> load() async {
    emit(state.copyWith(status: ReceiptsViewStatus.loading, errorMessage: null, clearItems: true));
    final result = await _repository.getReceipts(page: 0, size: _pageSize);
    result.fold(
      (failure) => emit(
        state.copyWith(status: ReceiptsViewStatus.failure, errorMessage: failure.message),
      ),
      (data) => emit(
        state.copyWith(
          status: ReceiptsViewStatus.success,
          receipts: data.receipts,
          page: data.page,
          hasMore: data.hasMore,
        ),
      ),
    );
  }

  Future<void> refresh() => load();

  Future<void> loadMore() async {
    if (!state.hasMore || state.status == ReceiptsViewStatus.loadingMore) return;
    emit(state.copyWith(status: ReceiptsViewStatus.loadingMore));
    final next = state.page + 1;
    final result = await _repository.getReceipts(page: next, size: _pageSize);
    result.fold(
      (failure) =>
          emit(state.copyWith(status: ReceiptsViewStatus.success, errorMessage: failure.message)),
      (data) => emit(
        state.copyWith(
          status: ReceiptsViewStatus.success,
          receipts: [...state.receipts, ...data.receipts],
          page: data.page,
          hasMore: data.hasMore,
        ),
      ),
    );
  }

  Future<PostReceipt?> loadOne(String id) async {
    final result = await _repository.getReceipt(id);
    return result.fold((_) => null, (r) => r);
  }
}
