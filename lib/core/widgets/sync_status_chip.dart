import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';
import 'package:motodi_go_mobile/features/nfc/domain/entities/nfc_entities.dart';

TextStyle nfcText({
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

class SyncStatusChip extends StatelessWidget {
  final NfcSyncStatus status;

  const SyncStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      NfcSyncStatus.localStored => (const Color(0xFFE8F0FF), AppColors.info),
      NfcSyncStatus.pendingSync => (const Color(0xFFFFF3C9), const Color(0xFF8B6509)),
      NfcSyncStatus.synced => (const Color(0xFFDDF5E6), AppColors.primary),
      NfcSyncStatus.rejected => (const Color(0xFFFFE8E8), AppColors.error),
      NfcSyncStatus.conflict => (const Color(0xFFFFE8D6), const Color(0xFF9A3412)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.labelFr.tr(context),
        style: nfcText(fontSize: 13, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
