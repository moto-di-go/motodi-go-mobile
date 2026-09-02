import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/widgets/app_error_view.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/offline/presentation/cubit/offline_maps_cubit.dart';
import 'package:motodi_go_mobile/features/offline/presentation/widgets/offline_widgets.dart';

class OfflineMapsPage extends StatelessWidget {
  const OfflineMapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OfflineMapsCubit>()..load(),
      child: const _OfflineMapsView(),
    );
  }
}

class OfflineMapsSelectPage extends StatelessWidget {
  const OfflineMapsSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    // MVP : packs prédéfinis uniquement — redirige vers la liste.
    return const OfflineMapsPage();
  }
}

class _OfflineMapsView extends StatelessWidget {
  const _OfflineMapsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => context.pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F1EA),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Cartes hors-ligne',
                      style: offlineText(fontSize: 26, fontWeight: FontWeight.w800),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(RouteConstants.offlineMapsSelect),
                    child: Text(
                      'Zones',
                      style: offlineText(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<OfflineMapsCubit, OfflineMapsState>(
                builder: (context, state) {
                  if (state.status == OfflineMapsStatus.loading && state.areas.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  if (state.status == OfflineMapsStatus.failure && state.areas.isEmpty) {
                    return AppErrorView(
                      message: state.errorMessage ?? 'Impossible de charger les zones.',
                      onRetry: () => context.read<OfflineMapsCubit>().load(),
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
                    children: [
                      if (state.usage != null) ...[
                        StorageUsageBar(usage: state.usage!),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        'Packs disponibles',
                        style: offlineText(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 10),
                      ...state.areas.map(
                        (area) => DownloadMapAreaCard(
                          area: area,
                          downloading: state.downloadingId == area.id,
                          progress: state.downloadingId == area.id ? state.downloadProgress : null,
                          onDownload: () => context.read<OfflineMapsCubit>().download(area.id),
                          onDelete: () => context.read<OfflineMapsCubit>().delete(area.id),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
