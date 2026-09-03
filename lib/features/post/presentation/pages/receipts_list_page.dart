import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/widgets/app_error_view.dart';
import 'package:motodi_go_mobile/core/widgets/receipt_card.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/intercity_formatters.dart';
import 'package:motodi_go_mobile/features/post/domain/entities/post_entities.dart';
import 'package:motodi_go_mobile/features/post/presentation/cubit/receipts_cubit.dart';
import 'package:motodi_go_mobile/features/post/presentation/widgets/post_ui.dart';

class ReceiptsListPage extends StatelessWidget {
  const ReceiptsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ReceiptsCubit>()..load(),
      child: const _ReceiptsListView(),
    );
  }
}

class _ReceiptsListView extends StatelessWidget {
  const _ReceiptsListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  PostBackButton(onTap: () => context.canPop() ? context.pop() : context.go(RouteConstants.profile)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Reçus', style: postText(fontSize: 28, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<ReceiptsCubit, ReceiptsState>(
                builder: (context, state) {
                  if (state.isLoading && state.receipts.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  if (state.status == ReceiptsViewStatus.failure && state.receipts.isEmpty) {
                    return AppErrorView(
                      message: state.errorMessage ?? 'Chargement des reçus impossible.',
                      onRetry: () => context.read<ReceiptsCubit>().refresh(),
                    );
                  }
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => context.read<ReceiptsCubit>().refresh(),
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (n) {
                        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 120) {
                          context.read<ReceiptsCubit>().loadMore();
                        }
                        return false;
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                        children: [
                          if (state.receipts.isEmpty)
                            const PostEmptyState(
                              title: 'Aucun reçu',
                              message: 'Vos reçus de paiement apparaîtront ici après un trajet payé.',
                            )
                          else
                            ...state.receipts.map(
                              (receipt) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ReceiptCard(
                                  receipt: receipt,
                                  onTap: () => _showReceiptDetail(context, receipt),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReceiptDetail(BuildContext context, PostReceipt receipt) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.receipt_long_rounded, size: 48, color: AppColors.secondary),
              const SizedBox(height: 14),
              Text(receipt.receiptNumber, style: postText(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                formatPriceFcfa(receipt.amount),
                style: postText(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                formatShortDate(receipt.issuedAt.toLocal()),
                style: postText(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 22),
              PostPrimaryButton(label: 'Fermer', onPressed: () => Navigator.of(sheetContext).pop()),
            ],
          ),
        );
      },
    );
  }
}
