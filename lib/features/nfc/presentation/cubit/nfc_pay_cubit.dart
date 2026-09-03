import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/nfc/domain/entities/nfc_entities.dart';
import 'package:motodi_go_mobile/features/nfc/domain/repositories/nfc_repository.dart';
import 'package:uuid/uuid.dart';

part 'nfc_pay_state.dart';

@injectable
class NfcPayCubit extends Cubit<NfcPayState> {
  final NfcRepository _repository;
  final Uuid _uuid = const Uuid();

  NfcPayCubit(this._repository) : super(const NfcPayState());

  Future<void> prepare({
    required double amount,
    String currency = 'XAF',
    String? bookingId,
    String? tripId,
  }) async {
    emit(
      state.copyWith(
        status: NfcPayStatus.checking,
        amount: amount,
        currency: currency,
        bookingId: bookingId,
        tripId: tripId,
        errorMessage: null,
        token: null,
      ),
    );

    final eligibility = await _repository.getEligibility();
    final elig = eligibility.fold<NfcEligibility?>((_) => null, (e) => e);
    if (elig == null || !elig.canPrepare) {
      emit(
        state.copyWith(
          status: NfcPayStatus.notEligible,
          eligibility: elig,
          errorMessage: eligibility.fold((f) => f.message, (_) => 'Paiement NFC indisponible.'),
        ),
      );
      return;
    }
    if (amount <= 0 || amount > elig.maxAmount || amount > elig.availableBalance) {
      emit(
        state.copyWith(
          status: NfcPayStatus.notEligible,
          eligibility: elig,
          errorMessage: 'Montant hors plafond ou solde insuffisant.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: NfcPayStatus.ready, eligibility: elig));
  }

  Future<void> issue() async {
    if (state.amount == null || state.amount! <= 0) return;
    emit(state.copyWith(status: NfcPayStatus.issuing, errorMessage: null));
    final result = await _repository.issueToken(
      amount: state.amount!,
      currency: state.currency,
      bookingId: state.bookingId,
      tripId: state.tripId,
      idempotencyKey: _uuid.v4(),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(status: NfcPayStatus.failure, errorMessage: failure.message),
      ),
      (token) => emit(state.copyWith(status: NfcPayStatus.issued, token: token)),
    );
  }
}
