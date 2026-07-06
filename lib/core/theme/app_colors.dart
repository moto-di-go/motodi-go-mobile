import 'package:flutter/material.dart';

// TODO: [TEMPLATE] Remplacer toutes les valeurs hex par votre palette de marque.
// Pour désactiver ce module : supprimer ce fichier et retirer les imports dans app_theme.dart
class AppColors {
  // --- Couleurs primaires de marque ---
  // TODO: [TEMPLATE] Couleur principale de votre application
  static const Color primary = Color(0xFF059669);
  static const Color primaryDark = Color(0xFF064E3B);
  static const Color primaryLight = Color(0xFF10B981);

  // TODO: [TEMPLATE] Couleur secondaire / accent
  static const Color secondary = Color(0xFFD4AF37);
  static const Color accent = Color(0xFFF59E0B);
  static const Color secondaryLight = Color(0xFFFCD34D);

  // --- Dégradés ---
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- Mode Clair ---
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF111827);
  static const Color onSurface = Color(0xFF374151);
  static const Color outline = Color(0xFFE5E7EB);

  // --- Mode Sombre ---
  static const Color primaryDarkTheme = Color(0xFF10B981);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color onBackgroundDark = Color(0xFFF1F5F9);
  static const Color onSurfaceDark = Color(0xFFCBD5E1);
  static const Color outlineDark = Color(0xFF334155);

  // --- Couleurs Sémantiques ---
  static const Color success = Color(0xFF059669);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // --- Texte Mode Clair ---
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // --- Texte Mode Sombre ---
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFFD1D5DB);
  static const Color textTertiaryDark = Color(0xFF9CA3AF);
}
