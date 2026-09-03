import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';
import 'package:motodi_go_mobile/features/wallet/presentation/widgets/wallet_widgets.dart';

/// Écran plein pour émettre un jeton (QR principal ; hint NFC Android optionnel).
class NfcTransferScreen extends StatelessWidget {
  final String signedToken;
  final double amount;
  final String currency;
  final Duration remaining;
  final bool useQr;
  final bool nfcHint;
  final String? statusMessage;
  final VoidCallback? onSwitchToQr;
  final VoidCallback? onTryNfc;
  final VoidCallback? onCancel;
  final VoidCallback? onExpired;

  const NfcTransferScreen({
    super.key,
    required this.signedToken,
    required this.amount,
    required this.currency,
    required this.remaining,
    this.useQr = true,
    this.nfcHint = false,
    this.statusMessage,
    this.onSwitchToQr,
    this.onTryNfc,
    this.onCancel,
    this.onExpired,
  });

  @override
  Widget build(BuildContext context) {
    final expired = remaining <= Duration.zero;
    final mm = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: onCancel ?? () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                  const Spacer(),
                  Text(
                    expired ? 'Expiré'.tr(context) : '$mm:$ss',
                    style: walletText(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: expired ? AppColors.error : Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                useQr ? 'Montrez ce QR au conducteur'.tr(context) : 'Approchez votre téléphone'.tr(context),
                textAlign: TextAlign.center,
                style: walletText(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                formatWalletAmount(amount, currency: currency),
                textAlign: TextAlign.center,
                style: walletText(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.secondary),
              ),
              const SizedBox(height: 8),
              Text(
                statusMessage ??
                    (useQr
                        ? 'Le paiement sera synchronisé plus tard. Ce n’est pas encore confirmé.'.tr(context)
                        : 'Émission NFC limitée — le QR reste le mode fiable.'.tr(context)),
                textAlign: TextAlign.center,
                style: walletText(fontSize: 14, color: Colors.white70, height: 1.4),
              ),
              const Spacer(),
              if (useQr && !expired)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: QrImageView(
                      data: signedToken,
                      version: QrVersions.auto,
                      size: 240,
                      backgroundColor: Colors.white,
                    ),
                  ),
                )
              else if (!useQr && !expired)
                Center(
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 4),
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    child: const Icon(Icons.nfc_rounded, size: 72, color: Colors.white),
                  ),
                )
              else
                Center(
                  child: Text(
                    'Jeton expiré'.tr(context),
                    style: walletText(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.error),
                  ),
                ),
              const Spacer(),
              if (nfcHint && useQr && onTryNfc != null)
                TextButton(
                  onPressed: onTryNfc,
                  child: Text(
                    'Essayer d’écrire sur un tag NFC'.tr(context),
                    style: walletText(fontSize: 13, color: Colors.white70),
                  ),
                ),
              if (!useQr && onSwitchToQr != null)
                TextButton(
                  onPressed: onSwitchToQr,
                  child: Text(
                    'Afficher le QR à la place'.tr(context),
                    style: walletText(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.secondary),
                  ),
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: signedToken));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Jeton copié'.tr(context))),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                icon: const Icon(Icons.copy_rounded),
                label: Text('Copier le jeton'.tr(context), style: walletText(fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
