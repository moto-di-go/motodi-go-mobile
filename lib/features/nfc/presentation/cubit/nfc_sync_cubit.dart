import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/nfc/domain/entities/nfc_entities.dart';
import 'package:motodi_go_mobile/features/nfc/domain/repositories/nfc_repository.dart';

part 'nfc_sync_state.dart';

/// Stub sync — appelle POST /offline/sync avec NFC_PAYMENT quand online.
@injectable
class NfcSyncCubit extends Cubit<NfcSyncState> {
  final NfcRepository _repository;

  NfcSyncCubit(this._repository) : super(const NfcSyncState());

  Future<void> syncAll() async {
    emit(state.copyWith(status: NfcSyncStatusView.syncing, errorMessage: null, batch: null));
    final pending = await _repository.listPending();
    final result = await _repository.syncPending(pending);
    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: NfcSyncStatusView.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (batch) async {
        final conflicts = batch.results.where((r) => r.isConflict).toList();
        final refreshed = await _repository.listPending();
        emit(
          state.copyWith(
            status: conflicts.isNotEmpty
                ? NfcSyncStatusView.conflict
                : NfcSyncStatusView.success,
            batch: batch,
            conflicts: conflicts,
            pendingAfter: refreshed,
          ),
        );
      },
    );
  }
}
