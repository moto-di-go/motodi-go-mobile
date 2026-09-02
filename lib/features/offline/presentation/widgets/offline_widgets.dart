import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/widgets/sync_status_chip.dart';
import 'package:motodi_go_mobile/features/nfc/domain/entities/nfc_entities.dart';
import 'package:motodi_go_mobile/features/nfc/presentation/widgets/nfc_widgets.dart';
import 'package:motodi_go_mobile/features/offline/domain/entities/offline_entities.dart';
import 'package:motodi_go_mobile/features/offline/presentation/cubit/connectivity_cubit.dart';
import 'package:motodi_go_mobile/features/urban/presentation/widgets/urban_bottom_sheet.dart';
import 'package:motodi_go_mobile/features/wallet/presentation/widgets/wallet_widgets.dart';

TextStyle offlineText({
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

String formatLastSync(DateTime? at) {
  if (at == null) return 'Jamais synchronisé';
  final local = at.toLocal();
  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');
  return 'Dernière sync · ${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')} $hh:$mm';
}

String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes o';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} Ko';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} Mo';
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        if (!state.showBanner) return const SizedBox.shrink();

        final (bg, fg, icon, title) = switch (state.status) {
          ConnectivityStatus.offline => (
            const Color(0xFF101512),
            Colors.white,
            Icons.cloud_off_rounded,
            'Hors-ligne',
          ),
          ConnectivityStatus.weakNetwork => (
            const Color(0xFF8B6509),
            Colors.white,
            Icons.signal_cellular_connected_no_internet_4_bar_rounded,
            'Réseau faible',
          ),
          ConnectivityStatus.online => (
            const Color(0xFF8B6509),
            Colors.white,
            Icons.sync_rounded,
            state.isSyncing ? 'Synchronisation…' : 'Synchronisation en attente',
          ),
        };

        return Material(
          color: bg,
          child: InkWell(
            onTap: () => context.push(RouteConstants.offline),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Row(
                  children: [
                    Icon(icon, color: fg, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: offlineText(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: fg,
                            ),
                          ),
                          Text(
                            state.pendingCount > 0
                                ? '${formatLastSync(state.lastSyncAt)} · ${state.pendingCount} en file'
                                : formatLastSync(state.lastSyncAt),
                            style: offlineText(fontSize: 12, color: fg.withValues(alpha: 0.85)),
                          ),
                        ],
                      ),
                    ),
                    if (state.pendingCount > 0 || state.isOffline)
                      Icon(Icons.chevron_right_rounded, color: fg.withValues(alpha: 0.9)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class OfflineOperationCard extends StatelessWidget {
  final OfflineOperation operation;
  final VoidCallback? onTap;

  const OfflineOperationCard({super.key, required this.operation, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    operation.type.labelFr,
                    style: offlineText(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
                SyncStatusChip(status: operation.syncStatus),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              formatLastSync(operation.queuedAt),
              style: offlineText(fontSize: 12, color: AppColors.textSecondary),
            ),
            if (operation.conflictMessage != null && operation.conflictMessage!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                operation.conflictMessage!,
                style: offlineText(fontSize: 13, color: AppColors.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DownloadMapAreaCard extends StatelessWidget {
  final OfflineMapArea area;
  final bool downloading;
  final double? progress;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;

  const DownloadMapAreaCard({
    super.key,
    required this.area,
    this.downloading = false,
    this.progress,
    this.onDownload,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
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
              const Icon(Icons.map_rounded, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  area.areaName,
                  style: offlineText(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                formatBytes(area.sizeBytes),
                style: offlineText(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            area.downloaded ? 'Téléchargé sur cet appareil' : 'Pack cartographique PMTiles / MBTiles',
            style: offlineText(fontSize: 13, color: AppColors.textSecondary),
          ),
          if (downloading) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              color: AppColors.primary,
              backgroundColor: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 6),
            Text(
              '${((progress ?? 0) * 100).toStringAsFixed(0)} %',
              style: offlineText(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              if (!area.downloaded)
                Expanded(
                  child: ElevatedButton(
                    onPressed: downloading ? null : onDownload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    child: Text(
                      downloading ? 'Téléchargement…' : 'Télécharger',
                      style: offlineText(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                )
              else
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDelete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    child: Text(
                      'Supprimer',
                      style: offlineText(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.error),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class StorageUsageBar extends StatelessWidget {
  final OfflineStorageUsage usage;

  const StorageUsageBar({super.key, required this.usage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Stockage hors-ligne',
                style: offlineText(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                '${formatBytes(usage.usedBytes)} / ${formatBytes(usage.maxBytes)}',
                style: offlineText(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: usage.ratio,
              minHeight: 10,
              color: AppColors.primary,
              backgroundColor: const Color(0xFFE8ECE6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cartes ${formatBytes(usage.mapsBytes)} · Cache ${formatBytes(usage.cacheBytes)} · File ${formatBytes(usage.queueBytes)}',
            style: offlineText(fontSize: 12, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

/// Variante générique — réutilise le sheet NFC pour les conflits offline.
Future<void> showOfflineSyncConflictSheet({
  required BuildContext context,
  required List<OfflineSyncItemResult> conflicts,
  VoidCallback? onRetry,
}) {
  return showSyncConflictSheet(
    context: context,
    conflicts: conflicts
        .map(
          (c) => NfcSyncItemResult(
            idempotencyKey: c.idempotencyKey,
            outcome: c.outcome,
            operationId: c.operationId,
            conflictCode: c.conflictCode,
            message: c.message,
          ),
        )
        .toList(),
    onRetry: onRetry,
  );
}

Future<void> showOfflineInfoSheet(BuildContext context, {required String title, required String body}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => UrbanBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: walletText(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Text(body, style: walletText(fontSize: 14, color: AppColors.textSecondary, height: 1.4)),
          const SizedBox(height: 16),
          UrbanPrimaryButton(label: 'Compris', onPressed: () => Navigator.of(ctx).pop()),
        ],
      ),
    ),
  );
}
