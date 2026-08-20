import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/widgets/app_error_view.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/home/presentation/widgets/home_figma_icons.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/intercity_formatters.dart';
import 'package:motodi_go_mobile/features/kyc/presentation/pages/kyc_pages.dart';
import 'package:motodi_go_mobile/features/notifications/domain/entities/app_notification.dart';
import 'package:motodi_go_mobile/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:motodi_go_mobile/features/notifications/presentation/widgets/notifications_figma_icons.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/widgets/profile_figma_icons.dart';

TextStyle _notifText({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w400,
  Color color = const Color(0xFF101512),
  double? height,
}) {
  return GoogleFonts.outfit(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
  );
}

class NotificationsTabPage extends StatelessWidget {
  const NotificationsTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NotificationsCubit>()..load(unreadOnly: true),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF6),
      body: SafeArea(
        child: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Notifications',
                          style: _notifText(fontSize: 32, fontWeight: FontWeight.w800, height: 1.1),
                        ),
                      ),
                      GestureDetector(
                        onTap: state.unreadCount > 0
                            ? () => context.read<NotificationsCubit>().markAllRead()
                            : null,
                        child: Text(
                          'Tout lire',
                          style: _notifText(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: state.unreadCount > 0
                                ? const Color(0xFF16A34A)
                                : const Color(0xFF9CA7A0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: _FilterTabs(
                    unreadOnly: state.unreadOnly,
                    unreadCount: state.unreadCount,
                    onUnread: () => context.read<NotificationsCubit>().load(unreadOnly: true),
                    onAll: () => context.read<NotificationsCubit>().load(unreadOnly: false),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(child: _NotificationsBody(state: state)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final bool unreadOnly;
  final int unreadCount;
  final VoidCallback onUnread;
  final VoidCallback onAll;

  const _FilterTabs({
    required this.unreadOnly,
    required this.unreadCount,
    required this.onUnread,
    required this.onAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEFE8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FilterChip(
              label: unreadCount > 0 ? 'Non lues · $unreadCount' : 'Non lues',
              selected: unreadOnly,
              onTap: onUnread,
            ),
          ),
          Expanded(
            child: _FilterChip(
              label: 'Toutes',
              selected: !unreadOnly,
              onTap: onAll,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? const [
                  BoxShadow(color: Color(0x1A101512), blurRadius: 8, offset: Offset(0, 2)),
                ]
              : null,
        ),
        child: Text(
          label,
          style: _notifText(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: selected ? const Color(0xFF101512) : const Color(0xFF7A857E),
          ),
        ),
      ),
    );
  }
}

class _NotificationsBody extends StatelessWidget {
  final NotificationsState state;

  const _NotificationsBody({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF16A34A)));
    }
    if (state.status == NotificationsStatus.failure && state.items.isEmpty) {
      return AppErrorView(
        message: state.errorMessage ?? 'Chargement des notifications impossible.',
        onRetry: () => context.read<NotificationsCubit>().load(),
      );
    }
    if (state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const MotodigoNotifGrayIcon(size: 72),
              const SizedBox(height: 22),
              Text(
                state.unreadOnly ? 'Aucune notification non lue' : 'Aucune notification pour le moment',
                textAlign: TextAlign.center,
                style: _notifText(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF54615A),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200) {
          context.read<NotificationsCubit>().loadMore();
        }
        return false;
      },
      child: RefreshIndicator(
        color: const Color(0xFF16A34A),
        onRefresh: () => context.read<NotificationsCubit>().load(),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: state.items.length + (state.status == NotificationsStatus.loadingMore ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index >= state.items.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator(color: Color(0xFF16A34A))),
              );
            }
            final item = state.items[index];
            return _NotificationCard(
              notification: item,
              onTap: () => _openNotification(context, item),
            );
          },
        ),
      ),
    );
  }

  void _openNotification(BuildContext context, AppNotification notification) {
    context.read<NotificationsCubit>().markRead(notification.id);
    if (notification.type == AppNotificationType.kycDecision) {
      final status = ValidationStatus.fromApi(notification.metadataStatus);
      context.push(
        RouteConstants.kycNotification,
        extra: KycNotificationPayload(
          title: notification.title,
          body: notification.body,
          status: status,
          reason: notification.metadata['reason']?.toString(),
          occurredAt: notification.createdAt,
        ),
      );
      return;
    }
    if (notification.type == AppNotificationType.payment) {
      context.go(RouteConstants.wallet);
      return;
    }
    if (notification.bookingId != null ||
        notification.type == AppNotificationType.subscription ||
        notification.type == AppNotificationType.confirmation ||
        notification.type == AppNotificationType.cancellation ||
        notification.type == AppNotificationType.departureReminder ||
        notification.type == AppNotificationType.statusChange) {
      context.go(RouteConstants.intercity);
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final kind = notification.visualKind;
    final style = _cardStyle(kind, notification.unread);
    final titleColor = kind == NotificationVisualKind.welcome
        ? const Color(0xFF101512)
        : const Color(0xFF16A34A);

    return Material(
      color: style.background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: style.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: style.iconBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: style.icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: _notifText(fontSize: 16, fontWeight: FontWeight.w800, color: titleColor, height: 1.25),
                          ),
                        ),
                        if (notification.unread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF16A34A),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: _notifText(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF54615A),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _formatRelative(notification.createdAt),
                      style: _notifText(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF9CA7A0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardStyle {
  final Color background;
  final Color border;
  final Color iconBackground;
  final Widget icon;

  const _CardStyle({
    required this.background,
    required this.border,
    required this.iconBackground,
    required this.icon,
  });
}

_CardStyle _cardStyle(NotificationVisualKind kind, bool unread) {
  return switch (kind) {
    NotificationVisualKind.success => const _CardStyle(
      background: Color(0xFFF3FBF6),
      border: Color(0xFFC9EBD4),
      iconBackground: Color(0xFF16A34A),
      icon: MotodigoNotifShieldWhiteIcon(size: 22),
    ),
    NotificationVisualKind.warning => const _CardStyle(
      background: Color(0xFFFFF8E8),
      border: Color(0xFFF3E0A8),
      iconBackground: Color(0xFFF5C518),
      icon: MotodigoNotifWarningTriangleIcon(size: 22),
    ),
    NotificationVisualKind.info => _CardStyle(
      background: unread ? const Color(0xFFF7F8F3) : Colors.white,
      border: const Color(0xFFE4E7DF),
      iconBackground: const Color(0xFFECEEE8),
      icon: const MotodigoNotifDocumentIcon(size: 22),
    ),
    NotificationVisualKind.welcome => _CardStyle(
      background: unread ? const Color(0xFFF7F8F3) : Colors.white,
      border: const Color(0xFFE4E7DF),
      iconBackground: const Color(0xFFE8F8EE),
      icon: const MotodigoMototaxiIcon(size: 22, color: Color(0xFF16A34A)),
    ),
  };
}

String _formatRelative(DateTime date) {
  final now = DateTime.now();
  final local = date.toLocal();
  final diff = now.difference(local);
  if (diff.inMinutes < 1) return "À l'instant";
  if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
  final yesterday = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
  final day = DateTime(local.year, local.month, local.day);
  if (day == yesterday) {
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return 'Hier · $hh:$mm';
  }
  if (local.year == now.year) return formatDayMonth(local);
  return '${formatDayMonth(local)} ${local.year}';
}
