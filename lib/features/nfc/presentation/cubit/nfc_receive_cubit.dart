import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/nfc/data/services/nfc_hardware_service.dart';
import 'package:motodi_go_mobile/features/nfc/domain/entities/nfc_entities.dart';
import 'package:motodi_go_mobile/features/nfc/domain/repositories/nfc_repository.dart';
import 'package:uuid/uuid.dart';

part 'nfc_receive_state.dart';

@injectable
class NfcReceiveCubit extends Cubit<NfcReceiveState> {
  final NfcRepository _repository;
  final NfcHardwareService _hardware;
  final Uuid _uuid = const Uuid();

  NfcReceiveCubit(this._repository, this._hardware) : super(const NfcReceiveState());

  Future<void> init({double? expectedAmount, String currency = 'XAF'}) async {
    final nfcOk = await _hardware.isNfcAvailable();
    emit(
      state.copyWith(
        status: NfcReceiveStatus.listening,
        expectedAmount: expectedAmount,
        currency: currency,
        nfcAvailable: nfcOk && !_hardware.forceQrOnly,
        forceQr: _hardware.forceQrOnly || !nfcOk,
      ),
    );
    if (nfcOk && !_hardware.forceQrOnly) {
      await _startNfc();
    }
  }

  Future<void> _startNfc() async {
    await _hardware.startReaderSession(
      onToken: (payload) => acceptPayload(payload),
      onError: (msg) => emit(state.copyWith(hintMessage: msg)),
    );
  }

  Future<void> acceptPayload(String raw) async {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      emit(state.copyWith(status: NfcReceiveStatus.failure, errorMessage: 'Jeton vide.'));
      return;
    }

    double amount = state.expectedAmount ?? 0;
    String currency = state.currency;
    String? bookingId;
    String? tripId;
    String? tokenId;
    var signedToken = trimmed;

    // Payload JSON optionnel {signedToken, amount, ...}
    if (trimmed.startsWith('{')) {
      try {
        final map = jsonDecode(trimmed) as Map<String, dynamic>;
        signedToken = map['signedToken']?.toString() ?? trimmed;
        amount = (map['amount'] as num?)?.toDouble() ?? amount;
        currency = map['currency']?.toString() ?? currency;
        bookingId = map['bookingId']?.toString();
        tripId = map['tripId']?.toString();
        tokenId = map['id']?.toString() ?? map['tokenId']?.toString();
      } catch (_) {}
    }

    if (state.expectedAmount != null && amount > 0 && (amount - state.expectedAmount!).abs() > 0.01) {
      emit(
        state.copyWith(
          status: NfcReceiveStatus.failure,
          errorMessage:
              'Montant reçu (${amount.toStringAsFixed(0)}) différent du montant attendu.',
        ),
      );
      return;
    }

    final pending = PendingNfcPayment(
      id: _uuid.v4(),
      signedToken: signedToken,
      amount: amount > 0 ? amount : (state.expectedAmount ?? 0),
      currency: currency,
      bookingId: bookingId,
      tripId: tripId,
      tokenId: tokenId,
      syncStatus: NfcSyncStatus.localStored,
      idempotencyKey: 'nfc-recv-${_uuid.v4()}',
      recordedAt: DateTime.now(),
      isInbound: true,
    );

    await _repository.savePending(pending);
    await _hardware.stopSession();
    emit(
      state.copyWith(
        status: NfcReceiveStatus.success,
        pending: pending,
        // Strict: local only — never « paiement confirmé »
        successMessage: NfcSyncStatus.localStored.labelFr,
      ),
    );
  }

  Future<void> acceptPaste(String value) => acceptPayload(value);

  @override
  Future<void> close() {
    _hardware.stopSession();
    return super.close();
  }
}
