import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/widgets/nfc_status_card.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/nfc/domain/entities/nfc_entities.dart';
import 'package:motodi_go_mobile/features/nfc/presentation/cubit/nfc_receive_cubit.dart';
import 'package:motodi_go_mobile/features/urban/presentation/widgets/urban_bottom_sheet.dart';
import 'package:motodi_go_mobile/features/wallet/presentation/widgets/wallet_widgets.dart';

class NfcReceivePage extends StatelessWidget {
  final double? expectedAmount;

  const NfcReceivePage({super.key, this.expectedAmount});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NfcReceiveCubit>()..init(expectedAmount: expectedAmount),
      child: const _NfcReceiveView(),
    );
  }
}

class _NfcReceiveView extends StatefulWidget {
  const _NfcReceiveView();

  @override
  State<_NfcReceiveView> createState() => _NfcReceiveViewState();
}

class _NfcReceiveViewState extends State<_NfcReceiveView> {
  final _pasteCtrl = TextEditingController();

  @override
  void dispose() {
    _pasteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<NfcReceiveCubit, NfcReceiveState>(
          builder: (context, state) {
            if (state.status == NfcReceiveStatus.success && state.pending != null) {
              return _success(context, state.pending!);
            }
            return Column(
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
                          'Recevoir un paiement',
                          style: walletText(fontSize: 24, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
                    children: [
                      NfcStatusCard(
                        title: state.forceQr ? 'Coller le jeton / QR' : 'Lecture NFC',
                        subtitle: state.expectedAmount != null
                            ? 'Montant attendu · ${formatWalletAmount(state.expectedAmount!)}'
                            : 'Scannez, lisez ou collez le jeton signé du passager.',
                        icon: state.nfcAvailable ? Icons.nfc_rounded : Icons.qr_code_2_rounded,
                        checklist: [
                          if (state.nfcAvailable)
                            const NfcChecklistRow(
                              label: 'NFC actif — approchez le téléphone',
                              ok: true,
                            ),
                          if (state.forceQr)
                            const NfcChecklistRow(
                              label: 'Parcours NFC masqué (iOS) — QR / collage',
                              ok: true,
                            ),
                        ],
                      ),
                      if (state.hintMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          state.hintMessage!,
                          style: walletText(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          state.errorMessage!,
                          style: walletText(fontSize: 13, color: AppColors.error),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Text(
                        'Collage manuel',
                        style: walletText(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _pasteCtrl,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Collez le signedToken ici',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      UrbanPrimaryButton(
                        label: 'Enregistrer localement',
                        onPressed: () {
                          context.read<NfcReceiveCubit>().acceptPaste(_pasteCtrl.text);
                        },
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Succès local = « ${NfcSyncStatus.localStored.labelFr} », '
                        'pas une confirmation serveur.',
                        style: walletText(fontSize: 12, color: AppColors.textTertiary, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _success(BuildContext context, PendingNfcPayment pending) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const Icon(Icons.phone_android_rounded, size: 64, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            NfcSyncStatus.localStored.labelFr,
            textAlign: TextAlign.center,
            style: walletText(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            formatWalletAmount(pending.amount, currency: pending.currency),
            textAlign: TextAlign.center,
            style: walletText(fontSize: 32, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          const Center(child: SyncStatusChip(status: NfcSyncStatus.localStored)),
          const SizedBox(height: 16),
          Text(
            'Synchronisez dès que le réseau est disponible. '
            'Le statut passera à « Synchronisé » uniquement après consommation serveur.',
            textAlign: TextAlign.center,
            style: walletText(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
          ),
          const Spacer(),
          UrbanPrimaryButton(
            label: 'Voir les en attente',
            onPressed: () => context.pushReplacement(RouteConstants.nfcPending),
          ),
          TextButton(
            onPressed: () => context.go(RouteConstants.wallet),
            child: Text('Retour wallet', style: walletText(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
