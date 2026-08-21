import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/wallet/domain/entities/wallet.dart';
import 'package:motodi_go_mobile/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:uuid/uuid.dart';

part 'deposit_state.dart';

@injectable
class DepositCubit extends Cubit<DepositState> {
  final WalletRepository _repository;
  Timer? _pollTimer;
  static const _uuid = Uuid();

  DepositCubit(this._repository) : super(const DepositState());

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }

  void selectProvider(PaymentProvider provider) {
    emit(state.copyWith(provider: provider, clearError: true));
  }

  void setAmount(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^\d]'), '');
    final amount = cleaned.isEmpty ? null : double.tryParse(cleaned);
    emit(state.copyWith(amountText: raw, amount: amount, clearError: true));
  }

  void setQuickAmount(int amount) {
    emit(state.copyWith(amountText: '$amount', amount: amount.toDouble(), clearError: true));
  }

  void setPhone(String raw) {
    emit(state.copyWith(phoneText: raw, clearError: true));
  }

  String? validateForm() {
    if (state.provider == null) return 'Choisissez un opérateur Mobile Money.';
    final amount = state.amount;
    if (amount == null || amount < 1) return 'Indiquez un montant d’au moins 1 XAF.';
    final phone = _normalizedPhone(state.phoneText);
    if (phone == null) {
      return 'Numéro invalide. Format attendu : +2376XXXXXXXX.';
    }
    return null;
  }

  Future<WalletDeposit?> submit() async {
    final validationError = validateForm();
    if (validationError != null) {
      emit(state.copyWith(errorMessage: validationError));
      return null;
    }

    final provider = state.provider!;
    final amount = state.amount!;
    final phone = _normalizedPhone(state.phoneText)!;
    final idempotencyKey = state.idempotencyKey ?? _uuid.v4();

    emit(
      state.copyWith(
        status: DepositFlowStatus.submitting,
        phoneText: phone,
        idempotencyKey: idempotencyKey,
        clearError: true,
      ),
    );

    final result = await _repository.createDeposit(
      provider: provider,
      amount: amount,
      phoneNumber: phone,
      idempotencyKey: idempotencyKey,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(status: DepositFlowStatus.form, errorMessage: failure.message));
        return null;
      },
      (deposit) {
        emit(
          state.copyWith(status: DepositFlowStatus.tracking, deposit: deposit, clearError: true),
        );
        _startPolling(deposit.id);
        return deposit;
      },
    );
  }

  Future<void> loadDeposit(String depositId) async {
    emit(state.copyWith(status: DepositFlowStatus.tracking, clearError: true));
    await refreshStatus(depositId: depositId);
    if (state.deposit != null && state.deposit!.status.isPending) {
      _startPolling(depositId);
    }
  }

  Future<void> refreshStatus({String? depositId}) async {
    final id = depositId ?? state.deposit?.id;
    if (id == null) return;

    emit(state.copyWith(isRefreshing: true, clearError: true));
    final result = await _repository.getDeposit(id);
    result.fold(
      (failure) => emit(state.copyWith(isRefreshing: false, errorMessage: failure.message)),
      (deposit) {
        emit(
          state.copyWith(isRefreshing: false, deposit: deposit, status: DepositFlowStatus.tracking),
        );
        if (deposit.status.isTerminal) {
          _pollTimer?.cancel();
        }
      },
    );
  }

  void _startPolling(String depositId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (isClosed) return;
      final deposit = state.deposit;
      if (deposit == null || deposit.status.isTerminal) {
        _pollTimer?.cancel();
        return;
      }
      refreshStatus(depositId: depositId);
    });
  }

  String? _normalizedPhone(String raw) {
    final trimmed = raw.trim().replaceAll(' ', '');
    if (RegExp(r'^\+237[6-9]\d{8}$').hasMatch(trimmed)) return trimmed;
    if (RegExp(r'^237[6-9]\d{8}$').hasMatch(trimmed)) return '+$trimmed';
    if (RegExp(r'^0[6-9]\d{8}$').hasMatch(trimmed)) return '+237${trimmed.substring(1)}';
    if (RegExp(r'^[6-9]\d{8}$').hasMatch(trimmed)) return '+237$trimmed';
    return null;
  }
}
