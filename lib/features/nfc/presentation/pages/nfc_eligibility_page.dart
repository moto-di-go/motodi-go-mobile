import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/widgets/app_error_view.dart';
import 'package:motodi_go_mobile/core/widgets/nfc_status_card.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/nfc/presentation/cubit/nfc_eligibility_cubit.dart';
import 'package:motodi_go_mobile/features/urban/presentation/widgets/urban_bottom_sheet.dart';
import 'package:motodi_go_mobile/features/wallet/presentation/widgets/wallet_widgets.dart';

class NfcEligibilityPage extends StatelessWidget {
  const NfcEligibilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NfcEligibilityCubit>()..load(),
      child: const _NfcEligibilityView(),
    );
  }
}

class _NfcEligibilityView extends StatelessWidget {
  const _NfcEligibilityView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<NfcEligibilityCubit, NfcEligibilityState>(
          builder: (context, state) {
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
                          'Paiement NFC',
                          style: walletText(fontSize: 26, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _body(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _body(BuildContext context, NfcEligibilityState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (state.status == NfcEligibilityStatus.failure || state.eligibility == null) {
      return AppErrorView(
        message: state.errorMessage ?? 'Vérification impossible.',
        onRetry: () => context.read<NfcEligibilityCubit>().load(),
      );
    }

    final elig = state.eligibility!;
    final canContinue = elig.canPrepare;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NfcStatusCard(
            title: canContinue ? 'Éligible' : 'Non éligible',
            subtitle: canContinue
                ? 'Vous pouvez préparer un jeton NFC hors-ligne.'
                : 'Corrigez les points ci-dessous avant de continuer.',
            icon: canContinue ? Icons.verified_rounded : Icons.block_rounded,
            iconColor: canContinue ? AppColors.primary : AppColors.error,
            checklist: [
              NfcChecklistRow(
                label: 'Wallet actif',
                ok: elig.walletActive,
              ),
              NfcChecklistRow(
                label: 'Solde disponible',
                ok: elig.availableBalance > 0,
                detail: formatWalletAmount(elig.availableBalance),
              ),
              NfcChecklistRow(
                label: 'Plafond NFC',
                ok: elig.maxAmount > 0,
                detail: formatWalletAmount(elig.maxAmount),
              ),
              NfcChecklistRow(
                label: elig.forceQrOnly ? 'Mode QR (iOS)' : 'NFC appareil',
                ok: elig.forceQrOnly || elig.deviceNfcSupported,
                detail: elig.forceQrOnly
                    ? 'Parcours NFC masqué — QR uniquement'
                    : (elig.deviceNfcSupported ? 'NFC activé' : 'QR de secours disponible'),
              ),
              if (elig.offlineQuotaRemaining != null)
                NfcChecklistRow(
                  label: 'Quota hors-ligne restant',
                  ok: elig.offlineQuotaRemaining! > 0,
                  detail: formatWalletAmount(elig.offlineQuotaRemaining!),
                ),
              ...elig.reasonsFr.map(
                (r) => NfcChecklistRow(label: r, ok: false),
              ),
            ],
          ),
          const Spacer(),
          UrbanPrimaryButton(
            label: 'Préparer un paiement',
            onPressed: canContinue
                ? () => context.push(RouteConstants.nfcPay)
                : null,
          ),
          if (!canContinue) ...[
            const SizedBox(height: 10),
            Text(
              'Le bouton reste désactivé tant que les conditions ne sont pas remplies.',
              textAlign: TextAlign.center,
              style: walletText(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => context.push(RouteConstants.nfcReceive),
            child: Text(
              'Mode conducteur — recevoir',
              style: walletText(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
