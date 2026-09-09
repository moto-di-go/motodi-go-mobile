import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/offline/domain/entities/offline_entities.dart';
import 'package:motodi_go_mobile/features/offline/domain/repositories/offline_repository.dart';
import 'package:motodi_go_mobile/features/offline/presentation/cubit/connectivity_cubit.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';
import 'package:motodi_go_mobile/features/offline/presentation/widgets/offline_widgets.dart';

class OfflineDashboardPage extends StatefulWidget {
  const OfflineDashboardPage({super.key});

  @override
  State<OfflineDashboardPage> createState() => _OfflineDashboardPageState();
}

class _OfflineDashboardPageState extends State<OfflineDashboardPage> {
  OfflineStorageUsage? _usage;
  int _pending = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = getIt<OfflineRepository>();
    final usage = await repo.storageUsage();
    final pending = await repo.listLocalOperations(pendingOnly: true);
    if (!mounted) return;
    setState(() {
      _usage = usage;
      _pending = pending.length;
    });
    context.read<ConnectivityCubit>().refreshPendingCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
            children: [
              Row(
                children: [
                  _BackBtn(onTap: () => context.pop()),
                  const SizedBox(width: 12),
                  Text(
                    'Mode hors-ligne'.tr(context),
                    style: offlineText(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              BlocBuilder<ConnectivityCubit, ConnectivityState>(
                builder: (context, state) {
                  final label = switch (state.status) {
                    ConnectivityStatus.online => 'En ligne'.tr(context),
                    ConnectivityStatus.offline => 'Hors-ligne'.tr(context),
                    ConnectivityStatus.weakNetwork => 'Réseau faible'.tr(context),
                  };
                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: offlineText(fontSize: 20, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text(
                          formatLastSync(state.lastSyncAt, context),
                          style: offlineText(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        if (_pending > 0) ...[
                          const SizedBox(height: 8),
                          Text(
                            '{count} opération(s) en attente de synchronisation'.tr(
                              context,
                              placeholders: {'count': '$_pending'},
                            ),
                            style: offlineText(fontSize: 13, color: const Color(0xFF8B6509)),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              if (_usage != null) ...[
                const SizedBox(height: 14),
                StorageUsageBar(usage: _usage!),
              ],
              const SizedBox(height: 22),
              _DashTile(
                icon: Icons.map_rounded,
                title: 'Cartes hors-ligne'.tr(context),
                subtitle: 'Douala, Yaoundé, axe'.tr(context),
                onTap: () => context.push(RouteConstants.offlineMaps),
              ),
              _DashTile(
                icon: Icons.queue_rounded,
                title: 'File d’opérations'.tr(context),
                subtitle: '{count} en attente'.tr(context, placeholders: {'count': '$_pending'}),
                onTap: () => context.push(RouteConstants.offlineQueue),
              ),
              _DashTile(
                icon: Icons.sync_rounded,
                title: 'Synchroniser'.tr(context),
                subtitle: 'Envoyer le lot au serveur'.tr(context),
                onTap: () => context.push(RouteConstants.offlineSync),
              ),
              _DashTile(
                icon: Icons.tune_rounded,
                title: 'Paramètres cache'.tr(context),
                subtitle: 'Limite et nettoyage'.tr(context),
                onTap: () => context.push(RouteConstants.offlineSettings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _BackBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: Color(0xFFF1F1EA), shape: BoxShape.circle),
        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF101512)),
      ),
    );
  }
}

class _DashTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DashTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.outline),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: offlineText(fontSize: 16, fontWeight: FontWeight.w800)),
                      Text(
                        subtitle,
                        style: offlineText(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFFC2C8C0)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
