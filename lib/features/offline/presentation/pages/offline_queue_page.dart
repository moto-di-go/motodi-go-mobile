import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/offline/presentation/cubit/offline_queue_cubit.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';
import 'package:motodi_go_mobile/features/offline/presentation/widgets/offline_widgets.dart';

class OfflineQueuePage extends StatelessWidget {
  const OfflineQueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OfflineQueueCubit>()..load(),
      child: const _OfflineQueueView(),
    );
  }
}

class _OfflineQueueView extends StatelessWidget {
  const _OfflineQueueView();

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
                  Text(
                    'File d’opérations'.tr(context),
                    style: offlineText(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<OfflineQueueCubit, OfflineQueueState>(
                builder: (context, state) {
                  if (state.status == OfflineQueueStatus.loading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  if (state.operations.isEmpty) {
                    return Center(
                      child: Text(
                        'Aucune opération en file'.tr(context),
                        style: offlineText(fontSize: 15, color: AppColors.textSecondary),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
                    itemCount: state.operations.length,
                    itemBuilder: (context, i) => OfflineOperationCard(operation: state.operations[i]),
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
