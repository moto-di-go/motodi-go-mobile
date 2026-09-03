import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/widgets/app_error_view.dart';
import 'package:motodi_go_mobile/core/widgets/support_context_card.dart';
import 'package:motodi_go_mobile/core/widgets/ticket_status_chip.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/intercity_formatters.dart';
import 'package:motodi_go_mobile/features/post/domain/entities/post_entities.dart';
import 'package:motodi_go_mobile/features/post/presentation/cubit/support_cubit.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';
import 'package:motodi_go_mobile/features/post/presentation/widgets/post_ui.dart';

class SupportFormPage extends StatelessWidget {
  final SupportContext? supportContext;

  const SupportFormPage({super.key, this.supportContext});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SupportCubit>()..initForm(context: supportContext),
      child: const _SupportFormView(),
    );
  }
}

class _SupportFormView extends StatelessWidget {
  const _SupportFormView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SupportCubit, SupportState>(
      listenWhen: (p, n) => p.formStatus != n.formStatus,
      listener: (context, state) {
        if (state.formStatus == SupportFormStatus.success && state.createdTicket != null) {
          context.pushReplacement(
            RouteConstants.supportTicketCreated,
            extra: state.createdTicket,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      PostBackButton(onTap: () => context.pop()),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Support'.tr(context), style: postText(fontSize: 28, fontWeight: FontWeight.w800)),
                      ),
                      TextButton(
                        onPressed: () => context.push(RouteConstants.supportTickets),
                        child: Text(
                          'Mes tickets'.tr(context),
                          style: postText(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                    children: [
                      Text(
                        'Décrivez votre problème. Une connexion internet est requise pour envoyer le ticket.'.tr(context),
                        style: postText(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      if (state.context != null) ...[
                        const SizedBox(height: 14),
                        SupportContextCard(contextData: state.context!),
                      ],
                      const SizedBox(height: 18),
                      Text('Catégorie'.tr(context), style: postText(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: SupportCategory.values.map((cat) {
                          final selected = state.category == cat;
                          return _Chip(
                            label: cat.labelFr,
                            selected: selected,
                            onTap: () => context.read<SupportCubit>().setCategory(cat),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Text('Priorité'.tr(context), style: postText(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: SupportPriority.values.map((p) {
                          final selected = state.priority == p;
                          return _Chip(
                            label: p.labelFr,
                            selected: selected,
                            onTap: () => context.read<SupportCubit>().setPriority(p),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Text('Sujet'.tr(context), style: postText(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
                      const SizedBox(height: 8),
                      TextField(
                        maxLength: 180,
                        onChanged: context.read<SupportCubit>().setSubject,
                        decoration: _inputDecoration('Ex. Problème de paiement'.tr(context)),
                      ),
                      const SizedBox(height: 8),
                      Text('Message'.tr(context), style: postText(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
                      const SizedBox(height: 8),
                      TextField(
                        maxLines: 5,
                        onChanged: context.read<SupportCubit>().setMessage,
                        decoration: _inputDecoration('Décrivez la situation…'.tr(context)),
                      ),
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          state.errorMessage!,
                          style: postText(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.error),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: PostPrimaryButton(
                    label: 'Envoyer'.tr(context),
                    isLoading: state.formStatus == SupportFormStatus.submitting,
                    onPressed: () => context.read<SupportCubit>().submit(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? AppColors.primary : AppColors.outline),
        ),
        child: Text(
          label,
          style: postText(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class SupportTicketCreatedPage extends StatelessWidget {
  final SupportTicket ticket;

  const SupportTicketCreatedPage({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Color(0xFFE8F8EE), shape: BoxShape.circle),
                child: const Icon(Icons.mark_email_read_outlined, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 22),
              Text(
                'Ticket créé'.tr(context),
                textAlign: TextAlign.center,
                style: postText(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                Localizations.localeOf(context).languageCode == 'en'
                    ? 'Acknowledgement: ${ticket.ticketNumber}\nOur team will respond as soon as possible.'
                    : 'Accusé de réception : ${ticket.ticketNumber}\nNotre équipe vous répondra dès que possible.',
                textAlign: TextAlign.center,
                style: postText(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.4),
              ),
              const Spacer(),
              PostPrimaryButton(
                label: 'Voir mes tickets'.tr(context),
                onPressed: () => context.go(RouteConstants.supportTickets),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go(RouteConstants.home),
                child: Text(
                  'Retour à l’accueil'.tr(context),
                  style: postText(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SupportTicketsPage extends StatelessWidget {
  const SupportTicketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SupportCubit>()..loadTickets(),
      child: const _SupportTicketsView(),
    );
  }
}

class _SupportTicketsView extends StatelessWidget {
  const _SupportTicketsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  PostBackButton(onTap: () => context.canPop() ? context.pop() : context.go(RouteConstants.support)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Mes tickets'.tr(context), style: postText(fontSize: 26, fontWeight: FontWeight.w800)),
                  ),
                  IconButton(
                    onPressed: () => context.push(RouteConstants.support),
                    icon: const Icon(Icons.add_rounded, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: BlocBuilder<SupportCubit, SupportState>(
                buildWhen: (p, n) => p.statusFilter != n.statusFilter,
                builder: (context, state) {
                  final filters = <SupportTicketStatus?>[null, ...SupportTicketStatus.values.where((s) => s != SupportTicketStatus.unknown)];
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filters.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final status = filters[index];
                      final selected = state.statusFilter == status;
                      return GestureDetector(
                        onTap: () => context.read<SupportCubit>().loadTickets(status: status),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: selected ? AppColors.primary : AppColors.outline),
                          ),
                          child: Text(
                            status?.labelFr ?? 'Tous'.tr(context),
                            style: postText(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: selected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<SupportCubit, SupportState>(
                builder: (context, state) {
                  if (state.listStatus == SupportListStatus.loading ||
                      state.listStatus == SupportListStatus.initial) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  if (state.listStatus == SupportListStatus.failure && state.tickets.isEmpty) {
                    return AppErrorView(
                      message: state.errorMessage ?? 'Chargement impossible.'.tr(context),
                      onRetry: () => context.read<SupportCubit>().refreshTickets(),
                    );
                  }
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => context.read<SupportCubit>().refreshTickets(),
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (n) {
                        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 120) {
                          context.read<SupportCubit>().loadMoreTickets();
                        }
                        return false;
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                        children: [
                          if (state.tickets.isEmpty)
                            PostEmptyState(
                              title: 'Aucun ticket'.tr(context),
                              message: 'Vos demandes support apparaîtront ici.'.tr(context),
                            )
                          else
                            ...state.tickets.map(
                              (ticket) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _TicketTile(
                                  ticket: ticket,
                                  onTap: () => context.push(RouteConstants.supportTicketDetailPath(ticket.id)),
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
}

class _TicketTile extends StatelessWidget {
  final SupportTicket ticket;
  final VoidCallback onTap;

  const _TicketTile({required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ticket.ticketNumber,
                      style: postText(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textTertiary),
                    ),
                  ),
                  TicketStatusChip(status: ticket.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(ticket.subject, style: postText(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(
                '${ticket.category.labelFr} · ${formatShortDate(ticket.createdAt.toLocal())}',
                style: postText(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SupportTicketDetailPage extends StatelessWidget {
  final String ticketId;

  const SupportTicketDetailPage({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SupportCubit>()..loadTicketDetail(ticketId),
      child: _SupportTicketDetailView(ticketId: ticketId),
    );
  }
}

class _SupportTicketDetailView extends StatelessWidget {
  final String ticketId;

  const _SupportTicketDetailView({required this.ticketId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<SupportCubit, SupportState>(
          builder: (context, state) {
            if (state.detailStatus == SupportDetailStatus.loading ||
                state.detailStatus == SupportDetailStatus.initial) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (state.detailStatus == SupportDetailStatus.failure || state.selectedTicket == null) {
              return AppErrorView(
                message: state.errorMessage ?? 'Ticket introuvable.'.tr(context),
                onRetry: () => context.read<SupportCubit>().loadTicketDetail(ticketId),
              );
            }
            final ticket = state.selectedTicket!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      PostBackButton(onTap: () => context.pop()),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(ticket.ticketNumber, style: postText(fontSize: 22, fontWeight: FontWeight.w800)),
                      ),
                      TicketStatusChip(status: ticket.status),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ticket.subject, style: postText(fontSize: 20, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 10),
                            Text(
                              '${ticket.category.labelFr} · Priorité ${ticket.priority.labelFr}',
                              style: postText(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              ticket.message,
                              style: postText(fontSize: 15, fontWeight: FontWeight.w500, height: 1.45),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              Localizations.localeOf(context).languageCode == 'en'
                                  ? 'Created on ${formatShortDate(ticket.createdAt.toLocal())}'
                                  : 'Créé le ${formatShortDate(ticket.createdAt.toLocal())}',
                              style: postText(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textTertiary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
