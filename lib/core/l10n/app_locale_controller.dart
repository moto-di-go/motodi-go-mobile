import 'package:flutter/material.dart';
import 'package:motodi_go_mobile/core/storage/auth_storage_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocaleController extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final code = preferences.getString(PreferenceKeys.preferredLocale);
    if (code == 'fr' || code == 'en') {
      _locale = Locale(code!);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode != 'fr' && locale.languageCode != 'en') return;
    if (_locale?.languageCode == locale.languageCode) return;

    _locale = Locale(locale.languageCode);
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(PreferenceKeys.preferredLocale, locale.languageCode);
  }

  static AppLocaleController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();
    assert(scope != null, 'AppLocaleScope not found in context');
    return scope!.notifier!;
  }
}

class AppLocaleScope extends InheritedNotifier<AppLocaleController> {
  const AppLocaleScope({super.key, required AppLocaleController controller, required super.child})
    : super(notifier: controller);
}
