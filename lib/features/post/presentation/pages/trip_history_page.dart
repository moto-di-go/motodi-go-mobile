import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/widgets/app_error_view.dart';
import 'package:motodi_go_mobile/core/widgets/trip_history_card.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/post/domain/entities/post_entities.dart';
import 'package:motodi_go_mobile/features/post/presentation/cubit/trip_history_cubit.dart';
import 'package:motodi_go_mobile/features/post/presentation/widgets/post_ui.dart';

class TripHistoryPage extends StatelessWidget {
  const TripHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TripHistoryCubit>()..load(),
      child: const _TripHistoryView(),
    );
  }
}

class _TripHistoryView extends StatelessWidget {
  const _TripHistoryView();

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
                    child: Text('Historique', style: postText(fontSize: 28, fontWeight: FontWeight.w800)),
                  ),
                  IconButton(
                    onPressed: () => _openFilters(context),
                    icon: const Icon(Icons.tune_rounded, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _Tabs(),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<TripHistoryCubit, TripHistoryState>(
                builder: (context, state) {
                  if (state.isLoading && state.items.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  if (state.status == TripHistoryViewStatus.failure && state.items.isEmpty) {
                    return AppErrorView(
                      message: state.errorMessage ?? 'Chargement impossible.',
                      onRetry: () => context.read<TripHistoryCubit>().refresh(),
                    );
                  }
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => context.read<TripHistoryCubit>().refresh(),
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (n) {
                        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 120) {
                          context.read<TripHistoryCubit>().loadMore();
                        }
                        return false;
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                        children: [
                          if (state.items.isEmpty)
                            PostEmptyState(
                              title: 'Aucun trajet',
                              message: switch (state.tab) {
                                TripHistoryTab.past => 'Vos trajets terminés apparaîtront ici.',
                                TripHistoryTab.upcoming => 'Aucun trajet à venir pour le moment.',
                                TripHistoryTab.cancelled => 'Aucun trajet annulé.',
                              },
                            )
                          else
                            ...state.items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: TripHistoryCard(
                                  item: item,
                                  onTap: () => context.push(
                                    RouteConstants.tripHistoryDetailPath(item.id),
                                    extra: item,
                                  ),
                                ),
                              ),
                            ),
                          if (state.status == TripHistoryViewStatus.loadingMore)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.primary),
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

  Future<void> _openFilters(BuildContext context) async {
    final cubit = context.read<TripHistoryCubit>();
    var tripType = cubit.state.tripTypeFilter;
    var payment = cubit.state.paymentStatusFilter;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Filtres', style: postText(fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  Text('Type', style: postText(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _FilterChip(
                        label: 'Tous',
                        selected: tripType == null,
                        onTap: () => setModal(() => tripType = null),
                      ),
                      _FilterChip(
                        label: 'Urbain',
                        selected: tripType == 'URBAN',
                        onTap: () => setModal(() => tripType = 'URBAN'),
                      ),
                      _FilterChip(
                        label: 'Interurbain',
                        selected: tripType == 'INTERCITY',
                        onTap: () => setModal(() => tripType = 'INTERCITY'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Paiement', style: postText(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _FilterChip(
                        label: 'Tous',
                        selected: payment == null,
                        onTap: () => setModal(() => payment = null),
                      ),
                      _FilterChip(
                        label: 'Payé',
                        selected: payment == 'PAID' || payment == 'CONFIRMED',
                        onTap: () => setModal(() => payment = 'PAID'),
                      ),
                      _FilterChip(
                        label: 'En attente',
                        selected: payment == 'PENDING',
                        onTap: () => setModal(() => payment = 'PENDING'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  PostPrimaryButton(
                    label: 'Appliquer',
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      cubit.applyFilters(tripType: tripType, paymentStatus: payment);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripHistoryCubit, TripHistoryState>(
      buildWhen: (p, n) => p.tab != n.tab,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F2ED),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: TripHistoryTab.values.map((tab) {
                final selected = state.tab == tab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => context.read<TripHistoryCubit>().setTab(tab),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        tab.labelFr,
                        style: postText(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : const Color(0xFFF1F2ED),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: postText(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
