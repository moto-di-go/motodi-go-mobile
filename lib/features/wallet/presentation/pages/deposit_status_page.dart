import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/widgets/app_error_view.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/urban/presentation/widgets/urban_bottom_sheet.dart';
import 'package:motodi_go_mobile/features/wallet/domain/entities/wallet.dart';
import 'package:motodi_go_mobile/features/wallet/presentation/cubit/deposit_cubit.dart';
import 'package:motodi_go_mobile/features/wallet/presentation/widgets/wallet_widgets.dart';

class DepositStatusPage extends StatelessWidget {
  final String depositId;

  const DepositStatusPage({super.key, required this.depositId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DepositCubit>()..loadDeposit(depositId),
      child: _DepositStatusView(depositId: depositId),
    );
  }
}

class _DepositStatusView extends StatelessWidget {
  final String depositId;

  const _DepositStatusView({required this.depositId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<DepositCubit, DepositState>(
          builder: (context, state) {
            final deposit = state.deposit;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 22, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go(RouteConstants.wallet),
                        icon: const Icon(Icons.close_rounded),
                      ),
                      Expanded(
                        child: Text(
                          'Suivi du dépôt',
                          style: walletText(fontSize: 26, fontWeight: FontWeight.w800, height: 1.1),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: deposit == null
                      ? (state.errorMessage != null
                            ? AppErrorView(
                                message: state.errorMessage!,
                                onRetry: () => context.read<DepositCubit>().loadDeposit(depositId),
                              )
                            : const Center(
                                child: CircularProgressIndicator(color: AppColors.primary),
                              ))
                      : _StatusContent(deposit: deposit, isRefreshing: state.isRefreshing),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatusContent extends StatelessWidget {
  final WalletDeposit deposit;
  final bool isRefreshing;

  const _StatusContent({required this.deposit, required this.isRefreshing});

  @override
  Widget build(BuildContext context) {
    final status = deposit.status;
    final (icon, title, subtitle, color) = switch (status) {
      PaymentStatus.confirmed => (
        Icons.check_circle_rounded,
        'Recharge confirmée',
        'Votre solde a été crédité avec succès.',
        AppColors.primary,
      ),
      PaymentStatus.failed => (
        Icons.cancel_rounded,
        'Recharge échouée',
        deposit.failureReason?.isNotEmpty == true
            ? deposit.failureReason!
            : 'Le paiement Mobile Money n’a pas abouti.',
        AppColors.error,
      ),
      PaymentStatus.expired => (
        Icons.timer_off_rounded,
        'Recharge expirée',
        'Le délai de confirmation Mobile Money est dépassé.',
        AppColors.error,
      ),
      _ => (
        Icons.hourglass_top_rounded,
        'En attente de confirmation',
        'Validez le paiement sur votre téléphone. Actualisez dans quelques secondes.',
        AppColors.secondary,
      ),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 88, color: color),
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: walletText(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: walletText(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Statut',
                            style: walletText(fontSize: 14, color: AppColors.textSecondary),
                          ),
                          const Spacer(),
                          WalletPaymentStatusChip(status: status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _row(
                        'Montant',
                        formatWalletAmount(deposit.amount, currency: deposit.currency),
                      ),
                      _row('Opérateur', deposit.provider?.labelFr ?? '—'),
                      _row('Téléphone', deposit.payerPhone ?? '—'),
                      _row('Référence', deposit.externalReference ?? deposit.id),
                      _row('Initié', formatWalletTime(deposit.initiatedAt)),
                      if (deposit.confirmedAt != null)
                        _row('Confirmé', formatWalletTime(deposit.confirmedAt)),
                    ],
                  ),
                ),
                if (status.isPending) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Astuce : le statut se met à jour automatiquement toutes les 5 secondes.',
                    textAlign: TextAlign.center,
                    style: walletText(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (status.isPending)
            UrbanPrimaryButton(
              label: 'Actualiser',
              isLoading: isRefreshing,
              onPressed: () => context.read<DepositCubit>().refreshStatus(),
            )
          else
            UrbanPrimaryButton(
              label: 'Retour au wallet',
              onPressed: () => context.go(RouteConstants.wallet),
            ),
          if (status == PaymentStatus.failed || status == PaymentStatus.expired) ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => context.pushReplacement(RouteConstants.walletDeposit),
              child: Text(
                'Réessayer une recharge',
                style: walletText(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: walletText(fontSize: 13, color: AppColors.textSecondary)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: walletText(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
