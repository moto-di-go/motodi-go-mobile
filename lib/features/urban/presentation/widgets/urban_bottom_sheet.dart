import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';

TextStyle urbanText({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w400,
  Color color = AppColors.textPrimary,
  double? height,
  double? letterSpacing,
}) {
  return GoogleFonts.outfit(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

class UrbanBottomSheet extends StatelessWidget {
  final Widget child;
  final double? maxHeight;
  final EdgeInsets padding;

  const UrbanBottomSheet({
    super.key,
    required this.child,
    this.maxHeight,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 20),
  });

  @override
  Widget build(BuildContext context) {
    final sheet = Container(
      width: double.infinity,
      padding: padding,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Color(0x1A101512), blurRadius: 24, offset: Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFDDE3DA),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
    if (maxHeight == null) return sheet;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight!),
      child: sheet,
    );
  }
}

class UrbanDemoBanner extends StatelessWidget {
  final String message;

  const UrbanDemoBanner({super.key, this.message = 'Données de démonstration'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3C9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3D77B)),
      ),
      child: Text(
        message,
        style: urbanText(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF8B6509)),
      ),
    );
  }
}

class UrbanPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const UrbanPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.55),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
              )
            : Text(
                label,
                style: urbanText(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
              ),
      ),
    );
  }
}

class UrbanTextLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;

  const UrbanTextLink({
    super.key,
    required this.label,
    required this.onTap,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: urbanText(fontSize: 15, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }
}
