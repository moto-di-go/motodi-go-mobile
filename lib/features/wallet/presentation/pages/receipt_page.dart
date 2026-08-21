import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/features/urban/presentation/widgets/urban_bottom_sheet.dart';
import 'package:motodi_go_mobile/features/wallet/domain/entities/wallet.dart';
import 'package:motodi_go_mobile/features/wallet/presentation/widgets/wallet_widgets.dart';

class ReceiptPage extends StatelessWidget {
  final String receiptId;
  final WalletReceipt? receipt;

  const ReceiptPage({super.key, required this.receiptId, this.receipt});

  @override
  Widget build(BuildContext context) {
    final data = receipt;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
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
                      'Reçu',
                      style: walletText(fontSize: 28, fontWeight: FontWeight.w800, height: 1.1),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: data == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'Reçu introuvable pour $receiptId.\nRelancez le paiement depuis la réservation.',
                          textAlign: TextAlign.center,
                          style: walletText(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.receipt_long_rounded,
                                size: 56,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Paiement enregistré',
                                style: walletText(fontSize: 22, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 8),
                              WalletPaymentStatusChip(status: data.status),
                              const SizedBox(height: 22),
                              _row('N° reçu', data.receiptNumber),
                              _row(
                                'Montant',
                                formatWalletAmount(data.amount, currency: data.currency),
                              ),
                              _row('Date', formatWalletTime(data.issuedAt)),
                              _row('Statut', data.status.labelFr),
                              if (data.bookingId != null) _row('Réservation', data.bookingId!),
                              if (data.pdfUrl != null && data.pdfUrl!.isNotEmpty)
                                _row('PDF', data.pdfUrl!),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
              child: UrbanPrimaryButton(
                label: 'Retour au wallet',
                onPressed: () => context.go(RouteConstants.wallet),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
