import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/offline/presentation/cubit/offline_settings_cubit.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';
import 'package:motodi_go_mobile/features/offline/presentation/widgets/offline_widgets.dart';

class OfflineSettingsPage extends StatelessWidget {
  const OfflineSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OfflineSettingsCubit>()..load(),
      child: const _OfflineSettingsView(),
    );
  }
}

class _OfflineSettingsView extends StatelessWidget {
  const _OfflineSettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<OfflineSettingsCubit, OfflineSettingsState>(
          builder: (context, state) {
            final s = state.settings;
            return ListView(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
              children: [
                Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => context.pop(),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F1EA),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Cache hors-ligne'.tr(context),
                      style: offlineText(fontSize: 26, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (state.usage != null) StorageUsageBar(usage: state.usage!),
                const SizedBox(height: 18),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          'Sync auto à la reconnexion'.tr(context),
                          style: offlineText(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        trailing: CupertinoSwitch(
                          value: s.autoSyncOnReconnect,
                          activeTrackColor: AppColors.primary,
                          onChanged: (v) => context.read<OfflineSettingsCubit>().update(
                                s.copyWith(autoSyncOnReconnect: v),
                              ),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: Text(
                          'Conserver les reçus'.tr(context),
                          style: offlineText(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        trailing: CupertinoSwitch(
                          value: s.keepReceipts,
                          activeTrackColor: AppColors.primary,
                          onChanged: (v) => context
                              .read<OfflineSettingsCubit>()
                              .update(s.copyWith(keepReceipts: v)),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: Text(
                          'Conserver les réservations'.tr(context),
                          style: offlineText(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        trailing: CupertinoSwitch(
                          value: s.keepBookings,
                          activeTrackColor: AppColors.primary,
                          onChanged: (v) => context
                              .read<OfflineSettingsCubit>()
                              .update(s.copyWith(keepBookings: v)),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: Text(
                          'Limite cache'.tr(context),
                          style: offlineText(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '{n} Mo'.tr(context, placeholders: {'n': '${s.maxCacheMb}'}),
                          style: offlineText(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: s.maxCacheMb <= 100
                                  ? null
                                  : () => context.read<OfflineSettingsCubit>().update(
                                        s.copyWith(maxCacheMb: s.maxCacheMb - 100),
                                      ),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            IconButton(
                              onPressed: () => context.read<OfflineSettingsCubit>().update(
                                    s.copyWith(maxCacheMb: s.maxCacheMb + 100),
                                  ),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                OutlinedButton(
                  onPressed: () async {
                    await context.read<OfflineSettingsCubit>().clearCaches();
                    if (context.mounted) {
                      showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          content: Text('Cache vidé'.tr(context)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: Text('OK'.tr(context)),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: Text(
                    'Vider le cache local'.tr(context),
                    style: offlineText(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.error),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
