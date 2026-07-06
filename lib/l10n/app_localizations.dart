import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// Nom de l'application
  ///
  /// In fr, this message translates to:
  /// **'Flutter Template App'**
  String get appName;

  /// No description provided for @common_ok.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get common_save;

  /// No description provided for @common_delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get common_edit;

  /// No description provided for @common_back.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get common_back;

  /// No description provided for @common_retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get common_retry;

  /// No description provided for @common_loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get common_loading;

  /// No description provided for @common_error.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue'**
  String get common_error;

  /// No description provided for @common_empty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun élément à afficher'**
  String get common_empty;

  /// No description provided for @common_search.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get common_search;

  /// No description provided for @common_confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get common_confirm;

  /// No description provided for @auth_login.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get auth_login;

  /// No description provided for @auth_logout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get auth_logout;

  /// No description provided for @auth_register.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get auth_register;

  /// No description provided for @auth_email.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail'**
  String get auth_email;

  /// No description provided for @auth_password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get auth_password;

  /// No description provided for @auth_forgot_password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get auth_forgot_password;

  /// No description provided for @auth_no_account.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ?'**
  String get auth_no_account;

  /// No description provided for @auth_already_account.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ?'**
  String get auth_already_account;

  /// No description provided for @errors_network.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion internet. Vérifiez votre réseau.'**
  String get errors_network;

  /// No description provided for @errors_server.
  ///
  /// In fr, this message translates to:
  /// **'Erreur serveur. Veuillez réessayer plus tard.'**
  String get errors_server;

  /// No description provided for @errors_unknown.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur inattendue est survenue.'**
  String get errors_unknown;

  /// No description provided for @errors_validation.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez vérifier les informations saisies.'**
  String get errors_validation;

  /// No description provided for @errors_session_expired.
  ///
  /// In fr, this message translates to:
  /// **'Session expirée. Veuillez vous reconnecter.'**
  String get errors_session_expired;

  /// No description provided for @navigation_home.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navigation_home;

  /// No description provided for @navigation_profile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get navigation_profile;

  /// No description provided for @navigation_settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get navigation_settings;

  /// No description provided for @navigation_notifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get navigation_notifications;

  /// No description provided for @example_title.
  ///
  /// In fr, this message translates to:
  /// **'Exemples'**
  String get example_title;

  /// No description provided for @example_empty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun exemple disponible.'**
  String get example_empty;

  /// No description provided for @example_detail.
  ///
  /// In fr, this message translates to:
  /// **'Détail'**
  String get example_detail;

  /// No description provided for @example_created_at.
  ///
  /// In fr, this message translates to:
  /// **'Créé le {date}'**
  String example_created_at(String date);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
