import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/offline/domain/entities/offline_entities.dart';
import 'package:motodi_go_mobile/features/offline/domain/repositories/offline_repository.dart';

part 'offline_sync_state.dart';

@injectable
class OfflineSyncCubit extends Cubit<OfflineSyncViewState> {
  final OfflineRepository _repository;

  OfflineSyncCubit(this._repository) : super(const OfflineSyncViewState());

  Future<void> syncAll() async {
    emit(
      state.copyWith(
        status: OfflineSyncViewStatus.syncing,
        errorMessage: null,
        batch: null,
        progress: 0.1,
      ),
    );
    final result = await _repository.syncPending();
    result.fold(
      (f) => emit(
        state.copyWith(
          status: OfflineSyncViewStatus.failure,
          errorMessage: f.message,
          progress: 0,
        ),
      ),
      (batch) {
        final conflicts = batch.conflicts;
        emit(
          state.copyWith(
            status: conflicts.isNotEmpty
                ? OfflineSyncViewStatus.conflict
                : OfflineSyncViewStatus.success,
            batch: batch,
            conflicts: conflicts,
            progress: 1,
          ),
        );
      },
    );
  }
}
