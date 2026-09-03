import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/nfc/data/services/nfc_hardware_service.dart';
import 'package:motodi_go_mobile/features/nfc/domain/entities/nfc_entities.dart';
import 'package:motodi_go_mobile/features/nfc/domain/repositories/nfc_repository.dart';

part 'nfc_emit_state.dart';

@injectable
class NfcEmitCubit extends Cubit<NfcEmitState> {
  final NfcRepository _repository;
  final NfcHardwareService _hardware;
  Timer? _ticker;

  NfcEmitCubit(this._repository, this._hardware) : super(const NfcEmitState());

  Future<void> load(String tokenId) async {
    emit(state.copyWith(status: NfcEmitStatus.loading, errorMessage: null));
    final result = await _repository.getToken(tokenId);
    await result.fold(
      (failure) async {
        emit(state.copyWith(status: NfcEmitStatus.failure, errorMessage: failure.message));
      },
      (token) async {
        final nfcOk = await _hardware.isNfcAvailable();
        final forceQr = _hardware.forceQrOnly || !nfcOk;
        emit(
          state.copyWith(
            status: token.isExpired ? NfcEmitStatus.expired : NfcEmitStatus.ready,
            token: token,
            remaining: token.remaining,
            useQr: true,
            nfcAvailable: nfcOk && !forceQr,
          ),
        );
        _startTicker();
      },
    );
  }

  void showQr() {
    _hardware.stopSession();
    emit(state.copyWith(useQr: true, statusMessage: null));
  }

  Future<void> tryNfcEmit() async {
    final token = state.token;
    if (token == null || !state.nfcAvailable) {
      emit(state.copyWith(useQr: true, statusMessage: 'NFC indisponible — QR affiché.'));
      return;
    }
    emit(state.copyWith(useQr: false, statusMessage: 'Approchez un tag NFC inscriptible…'));
    await _hardware.startEmitWriteSession(
      signedToken: token.signedToken,
      onWritten: () {
        emit(
          state.copyWith(
            status: NfcEmitStatus.emitted,
            statusMessage: 'Jeton écrit sur le tag. En attente de synchronisation côté conducteur.',
          ),
        );
      },
      onError: (msg) {
        emit(state.copyWith(useQr: true, statusMessage: msg));
      },
    );
  }

  void markEmittedLocally() {
    emit(
      state.copyWith(
        status: NfcEmitStatus.emitted,
        statusMessage: 'Jeton présenté. Le conducteur doit encore synchroniser.',
      ),
    );
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final token = state.token;
      if (token == null) return;
      final remaining = token.remaining;
      if (remaining <= Duration.zero) {
        _ticker?.cancel();
        _hardware.stopSession();
        emit(state.copyWith(status: NfcEmitStatus.expired, remaining: Duration.zero));
      } else {
        emit(state.copyWith(remaining: remaining));
      }
    });
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    _hardware.stopSession();
    return super.close();
  }
}
