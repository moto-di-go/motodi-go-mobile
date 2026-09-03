import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:motodi_go_mobile/features/nfc/domain/entities/nfc_entities.dart';
import 'package:motodi_go_mobile/features/nfc/domain/repositories/nfc_repository.dart';
import 'package:motodi_go_mobile/features/offline/domain/entities/offline_entities.dart';
import 'package:motodi_go_mobile/features/offline/domain/repositories/offline_repository.dart';

part 'connectivity_state.dart';

@lazySingleton
class ConnectivityCubit extends Cubit<ConnectivityState> {
  final Connectivity _connectivity;
  final InternetConnectionChecker _connectionChecker;
  final OfflineRepository _offlineRepository;
  final NfcRepository _nfcRepository;

  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _syncing = false;

  ConnectivityCubit(this._offlineRepository, this._nfcRepository)
      : _connectivity = Connectivity(),
        _connectionChecker = InternetConnectionChecker.createInstance(),
        super(ConnectivityState(lastSyncAt: _offlineRepository.lastSyncAt)) {
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final results = await _connectivity.checkConnectivity();
    await _onConnectivity(results);
    _sub = _connectivity.onConnectivityChanged.listen(_onConnectivity);
  }

  Future<int> _pendingCount() async {
    final local = await _offlineRepository.listLocalOperations(pendingOnly: true);
    final nfc = await _nfcRepository.listPending();
    final nfcPending = nfc
        .where(
          (e) =>
              e.syncStatus == NfcSyncStatus.localStored ||
              e.syncStatus == NfcSyncStatus.pendingSync ||
              e.syncStatus == NfcSyncStatus.conflict,
        )
        .length;
    return local.length + nfcPending;
  }

  Future<void> _onConnectivity(List<ConnectivityResult> results) async {
    final previous = state.status;
    final hasInterface = results.any((r) => r != ConnectivityResult.none);
    if (!hasInterface) {
      emit(state.copyWith(status: ConnectivityStatus.offline, pendingCount: state.pendingCount));
      return;
    }

    final hasInternet = await _connectionChecker.hasConnection;
    final next = hasInternet ? ConnectivityStatus.online : ConnectivityStatus.weakNetwork;

    final pendingCount = await _pendingCount();
    emit(
      state.copyWith(
        status: next,
        pendingCount: pendingCount,
        lastSyncAt: _offlineRepository.lastSyncAt,
      ),
    );

    final settings = await _offlineRepository.getSettings();
    final restored =
        (previous == ConnectivityStatus.offline || previous == ConnectivityStatus.weakNetwork) &&
        next == ConnectivityStatus.online;
    if (restored && settings.autoSyncOnReconnect && pendingCount > 0) {
      unawaited(syncNow());
    }
  }

  Future<void> refreshPendingCount() async {
    final pendingCount = await _pendingCount();
    emit(
      state.copyWith(
        pendingCount: pendingCount,
        lastSyncAt: _offlineRepository.lastSyncAt,
      ),
    );
  }

  Future<void> syncNow() async {
    if (_syncing) return;
    if (state.status != ConnectivityStatus.online) return;
    _syncing = true;
    emit(state.copyWith(isSyncing: true));
    final result = await _offlineRepository.syncPending();
    result.fold(
      (_) {
        emit(state.copyWith(isSyncing: false, lastSyncAt: _offlineRepository.lastSyncAt));
      },
      (batch) async {
        final pendingCount = await _pendingCount();
        emit(
          state.copyWith(
            isSyncing: false,
            lastSyncAt: _offlineRepository.lastSyncAt,
            pendingCount: pendingCount,
            lastBatch: batch,
          ),
        );
      },
    );
    _syncing = false;
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
