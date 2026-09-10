import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/widgets/app_error_view.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/urban/presentation/widgets/urban_bottom_sheet.dart';
import 'package:motodi_go_mobile/features/wallet/presentation/cubit/pay_booking_cubit.dart';
import 'package:motodi_go_mobile/features/wallet/presentation/widgets/wallet_widgets.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';

class PayBookingArgs {
  final String bookingId;
  final double? amount;
  final String? label;

  const PayBookingArgs({required this.bookingId, this.amount, this.label});
}

class PayBookingPage extends StatelessWidget {
  final String bookingId;
  final double? expectedAmount;
  final String? label;

  const PayBookingPage({super.key, required this.bookingId, this.expectedAmount, this.label});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<PayBookingCubit>()..load(bookingId: bookingId, expectedAmount: expectedAmount),
      child: _PayBookingView(bookingId: bookingId, label: label),
    );
  }
}

class _PayBookingView extends StatelessWidget {
  final String bookingId;
  final String? label;

  const _PayBookingView({required this.bookingId, this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<PayBookingCubit, PayBookingState>(
          listenWhen: (prev, next) =>
              (prev.errorMessage != next.errorMessage && next.errorMessage != null) ||
              prev.status != next.status,
          listener: (context, state) {
            if (state.errorMessage != null && state.status != PayBookingStatus.failure) {
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
            if (state.status == PayBookingStatus.success && state.payment != null) {
              final payment = state.payment!;
              final receipt = payment.receipt;
              if (receipt != null) {
                context.pushReplacement(
                  RouteConstants.walletReceiptPath(receipt.id),
                  extra: receipt,
                );
              } else {
                showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    content: Text('Paiement confirmé.'.tr(context)),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          context.go(RouteConstants.wallet);
                        },
                        child: Text('OK'.tr(context)),
                      ),
                    ],
                  ),
                );
              }
            }
          },
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
                          'Payer la réservation'.tr(context),
                          style: walletText(fontSize: 26, fontWeight: FontWeight.w800, height: 1.1),
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

  Widget _body(BuildContext context, PayBookingState state) {
    if (state.status == PayBookingStatus.loading || state.status == PayBookingStatus.initial) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (state.status == PayBookingStatus.failure && state.wallet == null) {
      return AppErrorView(
        message: state.errorMessage ?? 'Chargement impossible.'.tr(context),
        onRetry: () => context.read<PayBookingCubit>().load(
          bookingId: bookingId,
          expectedAmount: state.expectedAmount,
        ),
      );
    }

    final wallet = state.wallet!;
    final shortfall = state.expectedAmount == null
        ? null
        : (state.expectedAmount! - wallet.currentBalance).clamp(0, double.infinity);

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.hasInsufficientBalance)
            WalletInsufficientBanner(shortfall: shortfall?.toDouble()),
          if (wallet.isFrozen) const WalletFrozenBanner(),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Récapitulatif'.tr(context),
                  style: walletText(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                _row('Réservation'.tr(context), state.bookingId ?? '—'),
                if (label != null && label!.isNotEmpty) _row('Trajet'.tr(context), label!),
                _row(
                  'Montant'.tr(context),
                  state.expectedAmount == null
                      ? 'Déterminé à la confirmation'.tr(context)
                      : formatWalletAmount(state.expectedAmount!),
                ),
                _row(
                  'Solde wallet'.tr(context),
                  formatWalletAmount(wallet.currentBalance, currency: wallet.currency),
                ),
                _row('Statut wallet'.tr(context), wallet.status.labelFr.tr(context)),
              ],
            ),
          ),
          const Spacer(),
          UrbanPrimaryButton(
            label: 'Confirmer le paiement'.tr(context),
            isLoading: state.status == PayBookingStatus.paying,
            onPressed: state.canPay ? () => context.read<PayBookingCubit>().confirmPay() : null,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => context.push(
              RouteConstants.nfcPayWithQuery(
                amount: state.expectedAmount,
                bookingId: bookingId,
              ),
            ),
            child: Text(
              'Payer via NFC (hors-ligne)'.tr(context),
              style: walletText(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          if (state.hasInsufficientBalance) ...[
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => context.push(RouteConstants.walletDeposit),
              child: Text(
                'Recharger mon wallet'.tr(context),
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
            child: Text(label, style: walletText(fontSize: 14, color: AppColors.textSecondary)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: walletText(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
