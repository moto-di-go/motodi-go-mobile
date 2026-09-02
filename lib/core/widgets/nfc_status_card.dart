import 'package:flutter/material.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/widgets/sync_status_chip.dart';
import 'package:motodi_go_mobile/features/nfc/domain/entities/nfc_entities.dart';
import 'package:motodi_go_mobile/features/wallet/presentation/widgets/wallet_widgets.dart';

export 'package:motodi_go_mobile/core/widgets/sync_status_chip.dart' show SyncStatusChip;

class NfcStatusCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final NfcSyncStatus? syncStatus;
  final IconData icon;
  final Color? iconColor;
  final List<Widget>? checklist;
  final Widget? trailing;
  final VoidCallback? onTap;

  const NfcStatusCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.syncStatus,
    this.icon = Icons.nfc_rounded,
    this.iconColor,
    this.checklist,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor ?? AppColors.primary, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: walletText(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: walletText(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (syncStatus != null) SyncStatusChip(status: syncStatus!),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
          if (checklist != null && checklist!.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...checklist!,
          ],
        ],
      ),
    );
    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, child: content);
  }
}

class NfcChecklistRow extends StatelessWidget {
  final String label;
  final bool ok;
  final String? detail;

  const NfcChecklistRow({super.key, required this.label, required this.ok, this.detail});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 20,
            color: ok ? AppColors.primary : AppColors.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: walletText(fontSize: 14, fontWeight: FontWeight.w600)),
                if (detail != null && detail!.isNotEmpty)
                  Text(
                    detail!,
                    style: walletText(fontSize: 12, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
