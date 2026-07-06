import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_template_app/core/theme/app_colors.dart';

// TODO: [TEMPLATE] Remplacer 'Outfit' par votre police de marque.
// Pour changer la police : modifier fontFamily + les assets dans pubspec.yaml
class AppTypography {
  static const String fontFamily = 'Outfit';

  static TextTheme get lightTextTheme => getTextTheme(Brightness.light);
  static TextTheme get darkTextTheme => getTextTheme(Brightness.dark);

  static TextTheme getTextTheme(Brightness brightness, [String? family]) {
    final theme = TextTheme(
      displayLarge: _style(
        family,
      ).copyWith(fontSize: 57, fontWeight: FontWeight.w700, height: 1.12, letterSpacing: -0.25),
      displayMedium: _style(
        family,
      ).copyWith(fontSize: 45, fontWeight: FontWeight.w700, height: 1.15),
      displaySmall: _style(
        family,
      ).copyWith(fontSize: 36, fontWeight: FontWeight.w600, height: 1.25),
      headlineLarge: _style(
        family,
      ).copyWith(fontSize: 32, fontWeight: FontWeight.w600, height: 1.25),
      headlineMedium: _style(
        family,
      ).copyWith(fontSize: 28, fontWeight: FontWeight.w600, height: 1.28),
      headlineSmall: _style(
        family,
      ).copyWith(fontSize: 24, fontWeight: FontWeight.w600, height: 1.33),
      titleLarge: _style(family).copyWith(fontSize: 22, fontWeight: FontWeight.w500, height: 1.27),
      titleMedium: _style(
        family,
      ).copyWith(fontSize: 16, fontWeight: FontWeight.w500, height: 1.5, letterSpacing: 0.15),
      titleSmall: _style(
        family,
      ).copyWith(fontSize: 14, fontWeight: FontWeight.w500, height: 1.43, letterSpacing: 0.1),
      bodyLarge: _style(
        family,
      ).copyWith(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, letterSpacing: 0.5),
      bodyMedium: _style(
        family,
      ).copyWith(fontSize: 14, fontWeight: FontWeight.w400, height: 1.43, letterSpacing: 0.25),
      bodySmall: _style(
        family,
      ).copyWith(fontSize: 12, fontWeight: FontWeight.w400, height: 1.33, letterSpacing: 0.4),
      labelLarge: _style(
        family,
      ).copyWith(fontSize: 14, fontWeight: FontWeight.w500, height: 1.43, letterSpacing: 0.1),
      labelMedium: _style(
        family,
      ).copyWith(fontSize: 12, fontWeight: FontWeight.w500, height: 1.33, letterSpacing: 0.5),
      labelSmall: _style(
        family,
      ).copyWith(fontSize: 11, fontWeight: FontWeight.w500, height: 1.45, letterSpacing: 0.5),
    );

    return theme.apply(
      displayColor: brightness == Brightness.light
          ? AppColors.textPrimary
          : AppColors.textPrimaryDark,
      bodyColor: brightness == Brightness.light ? AppColors.textPrimary : AppColors.textPrimaryDark,
    );
  }

  static TextStyle _style([String? family]) {
    try {
      return GoogleFonts.getFont(
        family ?? fontFamily,
      ).copyWith(leadingDistribution: TextLeadingDistribution.even);
    } catch (_) {
      return TextStyle(
        fontFamily: family ?? fontFamily,
        leadingDistribution: TextLeadingDistribution.even,
      );
    }
  }
}
