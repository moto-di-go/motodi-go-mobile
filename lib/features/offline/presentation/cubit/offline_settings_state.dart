part of 'offline_settings_cubit.dart';

class OfflineSettingsState extends Equatable {
  final OfflineCacheSettings settings;
  final OfflineStorageUsage? usage;

  const OfflineSettingsState({
    this.settings = const OfflineCacheSettings(),
    this.usage,
  });

  OfflineSettingsState copyWith({
    OfflineCacheSettings? settings,
    OfflineStorageUsage? usage,
  }) {
    return OfflineSettingsState(
      settings: settings ?? this.settings,
      usage: usage ?? this.usage,
    );
  }

  @override
  List<Object?> get props => [settings, usage];
}
