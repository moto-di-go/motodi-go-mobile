import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/wallet/domain/entities/wallet.dart';
import 'package:motodi_go_mobile/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:uuid/uuid.dart';

part 'pay_booking_state.dart';

@injectable
class PayBookingCubit extends Cubit<PayBookingState> {
  final WalletRepository _repository;
  static const _uuid = Uuid();

  PayBookingCubit(this._repository) : super(const PayBookingState());

  Future<void> load({required String bookingId, double? expectedAmount}) async {
    emit(
      state.copyWith(
        status: PayBookingStatus.loading,
        bookingId: bookingId,
        expectedAmount: expectedAmount,
        clearError: true,
        clearPayment: true,
      ),
    );

    final result = await _repository.getWallet();
    result.fold(
      (failure) =>
          emit(state.copyWith(status: PayBookingStatus.failure, errorMessage: failure.message)),
      (wallet) => emit(state.copyWith(status: PayBookingStatus.ready, wallet: wallet)),
    );
  }

  Future<RidePayment?> confirmPay() async {
    final bookingId = state.bookingId;
    if (bookingId == null || bookingId.isEmpty) {
      emit(state.copyWith(errorMessage: 'Réservation introuvable.'));
      return null;
    }
    if (state.wallet?.canTransact != true) {
      emit(
        state.copyWith(
          errorMessage: state.wallet?.isFrozen == true
              ? 'Portefeuille gelé. Paiement impossible.'
              : 'Portefeuille indisponible pour un paiement.',
        ),
      );
      return null;
    }
    if (state.hasInsufficientBalance) {
      emit(state.copyWith(errorMessage: 'Solde insuffisant pour payer cette réservation.'));
      return null;
    }

    final idempotencyKey = state.idempotencyKey ?? _uuid.v4();
    emit(
      state.copyWith(
        status: PayBookingStatus.paying,
        idempotencyKey: idempotencyKey,
        clearError: true,
      ),
    );

    final result = await _repository.payBooking(
      bookingId: bookingId,
      idempotencyKey: idempotencyKey,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(status: PayBookingStatus.ready, errorMessage: failure.message));
        return null;
      },
      (payment) {
        emit(state.copyWith(status: PayBookingStatus.success, payment: payment));
        return payment;
      },
    );
  }
}
