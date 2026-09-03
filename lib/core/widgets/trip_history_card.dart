import 'package:flutter/material.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/intercity_formatters.dart';
import 'package:motodi_go_mobile/features/post/domain/entities/post_entities.dart';
import 'package:motodi_go_mobile/features/post/presentation/widgets/post_ui.dart';

class TripHistoryCard extends StatelessWidget {
  final TripHistoryItem item;
  final VoidCallback? onTap;

  const TripHistoryCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = item.status.toUpperCase();
    final (bg, fg) = switch (status) {
      'COMPLETED' => (const Color(0xFFEFFAF3), AppColors.primary),
      'CANCELLED' => (const Color(0xFFFFE8E8), AppColors.error),
      'CONFIRMED' || 'APPROACHING' || 'ON_BOARD' || 'BOOKED' || 'PAID' => (
        const Color(0xFFFFF3C9),
        const Color(0xFF8B6509),
      ),
      _ => (const Color(0xFFEEEFE8), AppColors.textSecondary),
    };

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
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
                      item.routeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: postText(fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
                    child: Text(
                      status,
                      style: postText(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                formatShortDate((item.completedAt ?? item.createdAt).toLocal()),
                style: postText(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textTertiary),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (item.amount != null)
                    Text(
                      formatPriceF(item.amount!),
                      style: postText(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                  const Spacer(),
                  if (item.paymentStatus != null)
                    Text(
                      item.paymentStatus!,
                      style: postText(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  if (item.ratingSubmitted) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.star_rounded, size: 18, color: AppColors.secondary),
                  ],
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFFC2C8C0)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
