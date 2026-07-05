import 'package:flutter/material.dart';
import 'package:flutter_template_app/core/theme/app_colors.dart';
import 'package:flutter_template_app/core/theme/app_typography.dart';

// Rôle : Définit les ThemeData light et dark de l'application (Material 3).
// Dépendances : app_colors.dart, app_typography.dart
// Désactiver : retirer les références à AppTheme dans main.dart et fournir votre propre ThemeData.
class AppTheme {
  static ThemeData lightTheme([String? fontFamily]) {
    final textTheme = AppTypography.getTextTheme(
      Brightness.light,
      fontFamily ?? AppTypography.fontFamily,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: fontFamily ?? AppTypography.fontFamily,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        tertiary: AppColors.accent,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerHighest: AppColors.background,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.outline,
        error: AppColors.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.1),
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: fontFamily ?? AppTypography.fontFamily,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }

  static ThemeData darkTheme([String? fontFamily]) {
    final textTheme = AppTypography.getTextTheme(
      Brightness.dark,
      fontFamily ?? AppTypography.fontFamily,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily ?? AppTypography.fontFamily,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDarkTheme,
        onPrimary: AppColors.backgroundDark,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        tertiary: AppColors.accent,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.onSurfaceDark,
        surfaceContainerHighest: AppColors.backgroundDark,
        onSurfaceVariant: AppColors.onSurfaceDark,
        outline: AppColors.outlineDark,
        error: AppColors.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.onBackgroundDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.outlineDark, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        indicatorColor: AppColors.primaryDarkTheme.withValues(alpha: 0.1),
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: fontFamily ?? AppTypography.fontFamily,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDarkTheme,
          foregroundColor: AppColors.backgroundDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryDarkTheme, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}
