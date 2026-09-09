import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';
import 'package:motodi_go_mobile/core/widgets/sync_status_chip.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/nfc/domain/entities/nfc_entities.dart';
import 'package:motodi_go_mobile/features/offline/presentation/cubit/connectivity_cubit.dart';
import 'package:motodi_go_mobile/features/offline/presentation/cubit/offline_sync_cubit.dart';
import 'package:motodi_go_mobile/features/offline/presentation/widgets/offline_widgets.dart';

class OfflineSyncPage extends StatelessWidget {
  const OfflineSyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OfflineSyncCubit>(),
      child: const _OfflineSyncView(),
    );
  }
}

class _OfflineSyncView extends StatelessWidget {
  const _OfflineSyncView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<OfflineSyncCubit, OfflineSyncViewState>(
          listenWhen: (p, n) => p.status != n.status,
          listener: (context, state) {
            if (state.status == OfflineSyncViewStatus.conflict && state.conflicts.isNotEmpty) {
              showOfflineSyncConflictSheet(
                context: context,
                conflicts: state.conflicts,
              );
            }
            if (state.status == OfflineSyncViewStatus.success ||
                state.status == OfflineSyncViewStatus.conflict) {
              context.read<ConnectivityCubit>().refreshPendingCount();
            }
          },
          builder: (context, state) {
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
                      'Synchronisation'.tr(context),
                      style: offlineText(fontSize: 26, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (state.status == OfflineSyncViewStatus.syncing
                                ? 'Synchronisation en cours…'
                                : 'Lot de synchronisation')
                            .tr(context),
                        style: offlineText(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 14),
                      LinearProgressIndicator(
                        value: state.status == OfflineSyncViewStatus.syncing
                            ? null
                            : (state.progress <= 0 ? 0 : state.progress),
                        color: AppColors.primary,
                        backgroundColor: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                        minHeight: 10,
                      ),
                      const SizedBox(height: 16),
                      if (state.errorMessage != null)
                        Text(
                          state.errorMessage!.tr(context),
                          style: offlineText(fontSize: 14, color: AppColors.error),
                        ),
                      if (state.batch != null) ...[
                        Text(
                          'Statut lot : {status}'.tr(
                            context,
                            placeholders: {'status': state.batch!.status},
                          ),
                          style: offlineText(fontSize: 14, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        ...state.batch!.results.map(
                          (r) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    r.idempotencyKey,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: offlineText(fontSize: 12),
                                  ),
                                ),
                                SyncStatusChip(
                                  status: r.isSynced
                                      ? NfcSyncStatus.synced
                                      : r.isConflict
                                          ? NfcSyncStatus.conflict
                                          : NfcSyncStatus.rejected,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                ElevatedButton(
                  onPressed: state.status == OfflineSyncViewStatus.syncing
                      ? null
                      : () => context.read<OfflineSyncCubit>().syncAll(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: Text(
                    'Lancer la synchronisation'.tr(context),
                    style: offlineText(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
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
