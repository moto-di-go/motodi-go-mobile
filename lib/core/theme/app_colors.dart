import 'package:flutter/material.dart';

// TODO: [TEMPLATE] Remplacer toutes les valeurs hex par votre palette de marque.
// Pour désactiver ce module : supprimer ce fichier et retirer les imports dans app_theme.dart
class AppColors {
  // --- Couleurs primaires de marque ---
  static const Color primary = Color(0xFF16A34A);
  static const Color primaryDark = Color(0xFF101512);
  static const Color primaryLight = Color(0xFFDDF5E6);

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
  static const Color background = Color(0xFFFAFAF6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF101512);
  static const Color onSurface = Color(0xFF3E4A42);
  static const Color outline = Color(0xFFDDE3DA);

  // --- Mode Sombre ---
  static const Color primaryDarkTheme = Color(0xFF16A34A);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color onBackgroundDark = Color(0xFFF1F5F9);
  static const Color onSurfaceDark = Color(0xFFCBD5E1);
  static const Color outlineDark = Color(0xFF334155);

  // --- Couleurs Sémantiques ---
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // --- Texte Mode Clair ---
  static const Color textPrimary = Color(0xFF101512);
  static const Color textSecondary = Color(0xFF5B6760);
  static const Color textTertiary = Color(0xFF8A968C);

  // --- Texte Mode Sombre ---
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFFD1D5DB);
  static const Color textTertiaryDark = Color(0xFF9CA3AF);
}
