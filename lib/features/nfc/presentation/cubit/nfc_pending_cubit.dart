import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/nfc/domain/entities/nfc_entities.dart';
import 'package:motodi_go_mobile/features/nfc/domain/repositories/nfc_repository.dart';

part 'nfc_pending_state.dart';

@injectable
class NfcPendingCubit extends Cubit<NfcPendingState> {
  final NfcRepository _repository;

  NfcPendingCubit(this._repository) : super(const NfcPendingState());

  Future<void> load() async {
    emit(state.copyWith(status: NfcPendingStatus.loading));
    final items = await _repository.listPending();
    emit(state.copyWith(status: NfcPendingStatus.success, items: items));
  }
}
