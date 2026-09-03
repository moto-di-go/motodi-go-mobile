import 'package:flutter/material.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/features/post/domain/entities/post_entities.dart';
import 'package:motodi_go_mobile/features/post/presentation/widgets/post_ui.dart';

class SupportContextCard extends StatelessWidget {
  final SupportContext contextData;

  const SupportContextCard({super.key, required this.contextData});

  @override
  Widget build(BuildContext context) {
    if (!contextData.hasContext) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFAF3),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFC9EBD4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contexte du signalement',
            style: postText(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          if (contextData.routeLabel != null)
            Text(contextData.routeLabel!, style: postText(fontSize: 15, fontWeight: FontWeight.w700)),
          if (contextData.statusLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              contextData.statusLabel!,
              style: postText(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
            ),
          ],
          if (contextData.tripId != null) ...[
            const SizedBox(height: 6),
            Text(
              'Trajet · ${contextData.tripId!.substring(0, contextData.tripId!.length.clamp(0, 8))}…',
              style: postText(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textTertiary),
            ),
          ],
        ],
      ),
    );
  }
}
