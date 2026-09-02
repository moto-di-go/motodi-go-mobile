import 'package:flutter/material.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/widgets/sync_status_chip.dart';
import 'package:motodi_go_mobile/features/nfc/domain/entities/nfc_entities.dart';
import 'package:motodi_go_mobile/features/urban/presentation/widgets/urban_bottom_sheet.dart';
import 'package:motodi_go_mobile/features/wallet/presentation/widgets/wallet_widgets.dart';

Future<void> showSyncConflictSheet({
  required BuildContext context,
  required List<NfcSyncItemResult> conflicts,
  VoidCallback? onRetry,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return UrbanBottomSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Conflit à résoudre',
              style: walletText(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Certaines opérations NFC n’ont pas pu être synchronisées. '
              'Le paiement n’est pas confirmé tant que le serveur n’a pas consommé le jeton.',
              style: walletText(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),
            ...conflicts.map(
              (c) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7F0),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFFD7B8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SyncStatusChip(status: NfcSyncStatus.conflict),
                    const SizedBox(height: 8),
                    Text(
                      c.conflictCode ?? 'CONFLICT',
                      style: walletText(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    if (c.message != null && c.message!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        c.message!,
                        style: walletText(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            UrbanPrimaryButton(
              label: 'Réessayer plus tard',
              onPressed: () {
                Navigator.of(ctx).pop();
                onRetry?.call();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

class PendingSyncCard extends StatelessWidget {
  final int pendingCount;
  final VoidCallback? onTap;

  const PendingSyncCard({super.key, required this.pendingCount, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (pendingCount <= 0) return const SizedBox.shrink();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E8),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE8D9A8)),
        ),
        child: Row(
          children: [
            const Icon(Icons.sync_problem_rounded, color: Color(0xFF8B6509)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'En attente de synchronisation',
                    style: walletText(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    pendingCount == 1
                        ? '1 paiement NFC local'
                        : '$pendingCount paiements NFC locaux',
                    style: walletText(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SyncStatusChip(status: NfcSyncStatus.pendingSync),
          ],
        ),
      ),
    );
  }
}
