import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/widgets/sync_status_chip.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/nfc/domain/entities/nfc_entities.dart';
import 'package:motodi_go_mobile/features/nfc/presentation/cubit/nfc_pending_cubit.dart';
import 'package:motodi_go_mobile/features/nfc/presentation/cubit/nfc_sync_cubit.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';
import 'package:motodi_go_mobile/features/nfc/presentation/widgets/nfc_widgets.dart';
import 'package:motodi_go_mobile/features/urban/presentation/widgets/urban_bottom_sheet.dart';
import 'package:motodi_go_mobile/features/wallet/presentation/widgets/wallet_widgets.dart';

class NfcPendingPage extends StatelessWidget {
  const NfcPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<NfcPendingCubit>()..load()),
        BlocProvider(create: (_) => getIt<NfcSyncCubit>()),
      ],
      child: const _NfcPendingView(),
    );
  }
}

class _NfcPendingView extends StatelessWidget {
  const _NfcPendingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocListener<NfcSyncCubit, NfcSyncState>(
          listenWhen: (p, n) => p.status != n.status,
          listener: (context, state) async {
            if (state.status == NfcSyncStatusView.conflict && state.conflicts.isNotEmpty) {
              await showSyncConflictSheet(
                context: context,
                conflicts: state.conflicts,
              );
              if (!context.mounted) return;
            } else if (state.status == NfcSyncStatusView.success) {
              showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  content: Text('Synchronisation terminée'.tr(context)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text('OK'.tr(context)),
                    ),
                  ],
                ),
              );
            } else if (state.status == NfcSyncStatusView.failure && state.errorMessage != null) {
              showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  content: Text(state.errorMessage!),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text('OK'.tr(context)),
                    ),
                  ],
                ),
              );
            }
            if (!context.mounted) return;
            if (state.status == NfcSyncStatusView.success ||
                state.status == NfcSyncStatusView.conflict) {
              context.read<NfcPendingCubit>().load();
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 22, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    ),
                    Expanded(
                      child: Text(
                        'Paiements NFC locaux'.tr(context),
                        style: walletText(fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<NfcPendingCubit, NfcPendingState>(
                  builder: (context, state) {
                    if (state.status == NfcPendingStatus.loading && state.items.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    }
                    if (state.items.isEmpty) {
                      return Center(
                        child: Text(
                          'Aucun paiement NFC en local.'.tr(context),
                          style: walletText(color: AppColors.textSecondary),
                        ),
                      );
                    }
                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () => context.read<NfcPendingCubit>().load(),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
                        itemCount: state.items.length,
                        itemBuilder: (context, index) {
                          final item = state.items[index];
                          return _PendingTile(item: item);
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                child: BlocBuilder<NfcSyncCubit, NfcSyncState>(
                  builder: (context, syncState) {
                    final syncing = syncState.status == NfcSyncStatusView.syncing;
                    return UrbanPrimaryButton(
                      label: syncing ? 'Synchronisation…'.tr(context) : 'Synchroniser maintenant'.tr(context),
                      onPressed: syncing
                          ? null
                          : () => context.read<NfcSyncCubit>().syncAll(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingTile extends StatelessWidget {
  final PendingNfcPayment item;

  const _PendingTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formatWalletAmount(item.amount, currency: item.currency),
                  style: walletText(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              SyncStatusChip(status: item.syncStatus),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.isInbound ? 'Reçu (conducteur)'.tr(context) : 'Émis (passager)'.tr(context),
            style: walletText(fontSize: 12, color: AppColors.textSecondary),
          ),
          if (item.conflictMessage != null && item.conflictMessage!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.conflictMessage!,
              style: walletText(fontSize: 12, color: AppColors.error),
            ),
          ],
        ],
      ),
    );
  }
}
