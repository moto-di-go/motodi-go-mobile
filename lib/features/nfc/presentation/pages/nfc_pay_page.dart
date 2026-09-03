import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/widgets/nfc_status_card.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/nfc/presentation/cubit/nfc_pay_cubit.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';
import 'package:motodi_go_mobile/features/urban/presentation/widgets/urban_bottom_sheet.dart';
import 'package:motodi_go_mobile/features/wallet/presentation/widgets/wallet_widgets.dart';

class NfcPayPage extends StatelessWidget {
  final double? amount;
  final String? bookingId;
  final String? tripId;

  const NfcPayPage({super.key, this.amount, this.bookingId, this.tripId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<NfcPayCubit>();
        if (amount != null && amount! > 0) {
          cubit.prepare(amount: amount!, bookingId: bookingId, tripId: tripId);
        }
        return cubit;
      },
      child: _NfcPayView(initialAmount: amount, bookingId: bookingId, tripId: tripId),
    );
  }
}

class _NfcPayView extends StatefulWidget {
  final double? initialAmount;
  final String? bookingId;
  final String? tripId;

  const _NfcPayView({this.initialAmount, this.bookingId, this.tripId});

  @override
  State<_NfcPayView> createState() => _NfcPayViewState();
}

class _NfcPayViewState extends State<_NfcPayView> {
  late final TextEditingController _amountCtrl;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: widget.initialAmount != null && widget.initialAmount! > 0
          ? widget.initialAmount!.round().toString()
          : '',
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<NfcPayCubit, NfcPayState>(
          listenWhen: (p, n) => p.status != n.status,
          listener: (context, state) {
            if (state.status == NfcPayStatus.issued && state.token != null) {
              context.pushReplacement(RouteConstants.nfcEmitPath(state.token!.id));
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
                          'Payer via NFC'.tr(context),
                          style: walletText(fontSize: 26, fontWeight: FontWeight.w800),
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
                        title: 'Préparer le jeton'.tr(context),
                        subtitle:
                            'Le jeton est signé côté serveur puis émis hors-ligne. Aucun « paiement confirmé » avant synchronisation.'.tr(context),
                        icon: Icons.contactless_rounded,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _amountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Montant (XAF)'.tr(context),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      if (widget.bookingId != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          '${'Réservation'.tr(context)} · ${widget.bookingId}',
                          style: walletText(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                      if (widget.tripId != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${'Trajet'.tr(context)} · ${widget.tripId}',
                          style: walletText(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          state.errorMessage!,
                          style: walletText(fontSize: 13, color: AppColors.error),
                        ),
                      ],
                      if (state.status == NfcPayStatus.ready && state.token == null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Prêt'.tr(context), style: walletText(fontSize: 16, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 6),
                              Text(
                                Localizations.localeOf(context).languageCode == 'en'
                                    ? 'Amount ${formatWalletAmount(state.amount ?? 0)} — confirm to get the token.'
                                    : 'Montant ${formatWalletAmount(state.amount ?? 0)} — validez pour obtenir le jeton.',
                                style: walletText(fontSize: 13, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      if (state.status == NfcPayStatus.checking || state.status == NfcPayStatus.issuing)
                        const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      else if (state.status == NfcPayStatus.ready)
                        UrbanPrimaryButton(
                          label: 'Émettre le jeton'.tr(context),
                          onPressed: () => context.read<NfcPayCubit>().issue(),
                        )
                      else
                        UrbanPrimaryButton(
                          label: 'Préparer NFC'.tr(context),
                          onPressed: () {
                            final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
                            context.read<NfcPayCubit>().prepare(
                              amount: amount,
                              bookingId: widget.bookingId,
                              tripId: widget.tripId,
                            );
                          },
                        ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          final booking = widget.bookingId;
                          if (booking != null && booking.isNotEmpty) {
                            context.push(RouteConstants.walletPayPath(booking));
                          } else {
                            context.go(RouteConstants.wallet);
                          }
                        },
                        child: Text(
                          'Payer via wallet'.tr(context),
                          style: walletText(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
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
}
