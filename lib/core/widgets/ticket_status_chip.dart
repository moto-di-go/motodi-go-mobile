import 'package:flutter/material.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/features/post/domain/entities/post_entities.dart';
import 'package:motodi_go_mobile/features/post/presentation/widgets/post_ui.dart';

class TicketStatusChip extends StatelessWidget {
  final SupportTicketStatus status;

  const TicketStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      SupportTicketStatus.open => (const Color(0xFFE8F0FF), AppColors.info),
      SupportTicketStatus.inProgress => (const Color(0xFFFFF3C9), const Color(0xFF8B6509)),
      SupportTicketStatus.waitingUser => (const Color(0xFFFFF0E0), AppColors.accent),
      SupportTicketStatus.resolved => (const Color(0xFFEFFAF3), AppColors.primary),
      SupportTicketStatus.closed => (const Color(0xFFEEEFE8), AppColors.textSecondary),
      SupportTicketStatus.unknown => (const Color(0xFFEEEFE8), AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        status.labelFr,
        style: postText(fontSize: 12, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
