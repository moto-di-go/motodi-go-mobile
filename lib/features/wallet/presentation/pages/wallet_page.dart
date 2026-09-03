import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/widgets/app_error_view.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/nfc/domain/entities/nfc_entities.dart';
import 'package:motodi_go_mobile/features/nfc/domain/repositories/nfc_repository.dart';
import 'package:motodi_go_mobile/features/nfc/presentation/widgets/nfc_widgets.dart';
import 'package:motodi_go_mobile/features/urban/presentation/widgets/urban_bottom_sheet.dart';
import 'package:motodi_go_mobile/features/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:motodi_go_mobile/features/wallet/presentation/widgets/wallet_widgets.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => getIt<WalletCubit>()..load(), child: const _WalletView());
  }
}

/// Alias shell — remplace l’ancien placeholder `WalletTabPage`.
class WalletTabPage extends WalletPage {
  const WalletTabPage({super.key});
}

class _WalletView extends StatelessWidget {
  const _WalletView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<WalletCubit, WalletState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                  child: Text(
                    'Portefeuille'.tr(context),
                    style: walletText(fontSize: 32, fontWeight: FontWeight.w800, height: 1.1),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(child: _WalletBody(state: state)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WalletBody extends StatelessWidget {
  final WalletState state;

  const _WalletBody({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.wallet == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (state.status == WalletViewStatus.failure && state.wallet == null) {
      return AppErrorView(
        message: state.errorMessage ?? 'Chargement du portefeuille impossible.'.tr(context),
        onRetry: () => context.read<WalletCubit>().load(),
      );
    }

    final wallet = state.wallet!;
    final canAct = wallet.canTransact;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<WalletCubit>().refresh(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 120) {
            context.read<WalletCubit>().loadMore();
          }
          return false;
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
          children: [
            if (state.isFrozen) const WalletFrozenBanner(),
            FutureBuilder<List<PendingNfcPayment>>(
              future: getIt<NfcRepository>().listPending(),
              builder: (context, snap) {
                final pending = (snap.data ?? const [])
                    .where(
                      (e) =>
                          e.syncStatus == NfcSyncStatus.localStored ||
                          e.syncStatus == NfcSyncStatus.pendingSync ||
                          e.syncStatus == NfcSyncStatus.conflict,
                    )
                    .length;
                return PendingSyncCard(
                  pendingCount: pending,
                  onTap: () => context.push(RouteConstants.nfcPending),
                );
              },
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Solde disponible'.tr(context),
                        style: walletText(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      WalletStatusChip(status: wallet.status),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    formatWalletAmount(wallet.currentBalance, currency: wallet.currency),
                    style: walletText(fontSize: 36, fontWeight: FontWeight.w800, height: 1.05),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${'Mis à jour'.tr(context)} ${formatWalletTime(state.lastRefreshedAt ?? wallet.lastUpdatedAt)}',
                    style: walletText(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: WalletActionButton(
                    label: 'Recharger'.tr(context),
                    icon: Icons.add_card_rounded,
                    primary: true,
                    onTap: canAct ? () => context.push(RouteConstants.walletDeposit) : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: WalletActionButton(
                    label: 'Payer'.tr(context),
                    icon: Icons.payments_outlined,
                    onTap: canAct ? () => _openPaySheet(context) : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: WalletActionButton(
                    label: 'Paiement NFC'.tr(context),
                    icon: Icons.nfc_rounded,
                    onTap: canAct ? () => context.push(RouteConstants.nfcEligibility) : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: WalletActionButton(
                    label: 'Historique'.tr(context),
                    icon: Icons.history_rounded,
                    onTap: () {
                      context.read<WalletCubit>().refresh();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: WalletActionButton(
                    label: 'Recevoir NFC'.tr(context),
                    icon: Icons.phone_android_rounded,
                    onTap: () => context.push(RouteConstants.nfcReceive),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'Mouvements récents'.tr(context),
              style: walletText(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (state.entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: WalletEmptyState(
                  message: 'Aucun mouvement pour le moment.\nRechargez votre wallet pour commencer.'.tr(context),
                  actionLabel: canAct ? 'Recharger'.tr(context) : null,
                  onAction: canAct ? () => context.push(RouteConstants.walletDeposit) : null,
                ),
              )
            else
              ...state.entries.map((entry) => WalletLedgerTile(entry: entry)),
            if (state.status == WalletViewStatus.loadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.primary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPaySheet(BuildContext context) async {
    final controller = TextEditingController();
    final bookingId = await showWalletSheet<String>(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Payer une réservation'.tr(context),
            style: walletText(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Saisissez l’identifiant de la réservation à régler avec votre wallet.'.tr(context),
            style: walletText(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'ID réservation'.tr(context),
              hintText: 'UUID de la réservation'.tr(context),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 16),
          UrbanPrimaryButton(
            label: 'Continuer'.tr(context),
            onPressed: () {
              final value = controller.text.trim();
              if (value.isEmpty) return;
              Navigator.of(context).pop(value);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
    if (bookingId == null || !context.mounted) return;
    context.push(RouteConstants.walletPayPath(bookingId));
  }
}
