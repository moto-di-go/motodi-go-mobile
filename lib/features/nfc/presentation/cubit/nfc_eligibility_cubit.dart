import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/nfc/domain/entities/nfc_entities.dart';
import 'package:motodi_go_mobile/features/nfc/domain/repositories/nfc_repository.dart';

part 'nfc_eligibility_state.dart';

@injectable
class NfcEligibilityCubit extends Cubit<NfcEligibilityState> {
  final NfcRepository _repository;

  NfcEligibilityCubit(this._repository) : super(const NfcEligibilityState());

  Future<void> load() async {
    emit(state.copyWith(status: NfcEligibilityStatus.loading, errorMessage: null));
    final result = await _repository.getEligibility();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: NfcEligibilityStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (eligibility) => emit(
        state.copyWith(
          status: NfcEligibilityStatus.success,
          eligibility: eligibility,
        ),
      ),
    );
  }
}
