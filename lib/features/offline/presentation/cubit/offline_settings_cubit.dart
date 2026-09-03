import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/offline/domain/entities/offline_entities.dart';
import 'package:motodi_go_mobile/features/offline/domain/repositories/offline_repository.dart';

part 'offline_settings_state.dart';

@injectable
class OfflineSettingsCubit extends Cubit<OfflineSettingsState> {
  final OfflineRepository _repository;

  OfflineSettingsCubit(this._repository) : super(const OfflineSettingsState());

  Future<void> load() async {
    final settings = await _repository.getSettings();
    final usage = await _repository.storageUsage();
    emit(state.copyWith(settings: settings, usage: usage));
  }

  Future<void> update(OfflineCacheSettings settings) async {
    await _repository.saveSettings(settings);
    emit(state.copyWith(settings: settings));
  }

  Future<void> clearCaches() async {
    final s = state.settings;
    await _repository.clearCaches(
      bookings: !s.keepBookings,
      receipts: !s.keepReceipts,
      maps: false,
    );
    // Force clear both when user taps clear
    await _repository.clearCaches(bookings: true, receipts: true);
    final usage = await _repository.storageUsage();
    emit(state.copyWith(usage: usage));
  }
}
