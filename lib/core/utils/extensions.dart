import 'package:flutter/material.dart';
import 'package:flutter_template_app/l10n/app_localizations.dart';

// Rôle : Extensions utilitaires globales sur les types Flutter/Dart.
extension ContextExtensions on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
}

extension StringExtensions on String {
  String get capitalize => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  bool get isEmail => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}').hasMatch(this);
}
