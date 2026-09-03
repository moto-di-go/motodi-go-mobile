import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/intercity_formatters.dart';
import 'package:motodi_go_mobile/features/wallet/domain/entities/wallet.dart';

TextStyle walletText({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w400,
  Color color = AppColors.textPrimary,
  double? height,
}) {
  return GoogleFonts.outfit(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
  );
}

String formatWalletAmount(double amount, {String currency = 'XAF'}) {
  final label = currency.toUpperCase() == 'XAF' ? 'XAF' : currency;
  return '${_group(amount)} $label';
}

String formatWalletTime(DateTime? date) {
  if (date == null) return '—';
  final local = date.toLocal();
  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');
  return '${formatShortDate(local)} · $hh:$mm';
}

String _group(double amount) {
  final rounded = amount.round();
  final text = rounded.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(text[i]);
  }
  return buffer.toString();
}

class WalletStatusChip extends StatelessWidget {
  final WalletStatus status;

  const WalletStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      WalletStatus.active => (const Color(0xFFDDF5E6), AppColors.primary),
      WalletStatus.frozen => (const Color(0xFFFFE8E8), AppColors.error),
      WalletStatus.closed => (const Color(0xFFEEEFE8), AppColors.textSecondary),
      WalletStatus.unknown => (const Color(0xFFEEEFE8), AppColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.labelFr,
        style: walletText(fontSize: 13, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

class WalletPaymentStatusChip extends StatelessWidget {
  final PaymentStatus status;

  const WalletPaymentStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      PaymentStatus.confirmed => (const Color(0xFFDDF5E6), AppColors.primary),
      PaymentStatus.pendingCallback ||
      PaymentStatus.initiated => (const Color(0xFFFFF3C9), const Color(0xFF8B6509)),
      PaymentStatus.failed || PaymentStatus.expired => (const Color(0xFFFFE8E8), AppColors.error),
      PaymentStatus.refunded => (const Color(0xFFE8F0FF), AppColors.info),
      PaymentStatus.unknown => (const Color(0xFFEEEFE8), AppColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.labelFr,
        style: walletText(fontSize: 13, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

class WalletActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool primary;

  const WalletActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 88,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: primary ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: primary ? null : Border.all(color: AppColors.outline),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: primary ? Colors.white : AppColors.primary, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: walletText(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: primary ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WalletLedgerTile extends StatelessWidget {
  final LedgerEntry entry;

  const WalletLedgerTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final credit = entry.type.isCredit;
    final sign = credit ? '+' : '−';
    final color = credit ? AppColors.primary : AppColors.textPrimary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: credit ? const Color(0xFFDDF5E6) : const Color(0xFFEEEFE8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              credit ? Icons.south_west_rounded : Icons.north_east_rounded,
              color: credit ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.type.labelFr,
                  style: walletText(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.reference?.isNotEmpty == true
                      ? entry.reference!
                      : formatWalletTime(entry.bookedAt),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: walletText(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign${formatWalletAmount(entry.amount, currency: entry.currency)}',
                style: walletText(fontSize: 14, fontWeight: FontWeight.w800, color: color),
              ),
              const SizedBox(height: 2),
              Text(
                formatWalletTime(entry.bookedAt),
                style: walletText(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WalletEmptyState extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const WalletEmptyState({super.key, required this.message, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 72,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: walletText(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              TextButton(
                onPressed: onAction,
                child: Text(
                  actionLabel!,
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
      ),
    );
  }
}

class WalletFrozenBanner extends StatelessWidget {
  const WalletFrozenBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF5C2C2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Portefeuille gelé. Recharge et paiements temporairement indisponibles.',
              style: walletText(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8B1E1E),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WalletInsufficientBanner extends StatelessWidget {
  final double? shortfall;

  const WalletInsufficientBanner({super.key, this.shortfall});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3C9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3D77B)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFF8B6509)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              shortfall == null
                  ? 'Solde insuffisant pour finaliser ce paiement.'
                  : 'Solde insuffisant. Il manque ${formatWalletAmount(shortfall!)}.',
              style: walletText(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF8B6509),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<T?> showWalletSheet<T>({
  required BuildContext context,
  required Widget child,
  double? maxHeight,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final bottom = MediaQuery.viewInsetsOf(context).bottom;
      return Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: Container(
          width: double.infinity,
          constraints: maxHeight == null ? null : BoxConstraints(maxHeight: maxHeight),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [BoxShadow(color: Color(0x1A101512), blurRadius: 24, offset: Offset(0, -4))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE3DA),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(child: child),
            ],
          ),
        ),
      );
    },
  );
}
