import 'package:flutter/material.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';

class RatingStars extends StatelessWidget {
  final int value;
  final ValueChanged<int>? onChanged;
  final double size;
  final bool readOnly;

  const RatingStars({
    super.key,
    required this.value,
    this.onChanged,
    this.size = 40,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final star = index + 1;
        final selected = star <= value;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: readOnly || onChanged == null ? null : () => onChanged!(star),
            child: Icon(
              selected ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size,
              color: selected ? AppColors.secondary : const Color(0xFFD0D5CC),
            ),
          ),
        );
      }),
    );
  }
}
