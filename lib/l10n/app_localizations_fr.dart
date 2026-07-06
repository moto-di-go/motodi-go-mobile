// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Flutter Template App';

  @override
  String get common_ok => 'OK';

  @override
  String get common_cancel => 'Annuler';

  @override
  String get common_save => 'Enregistrer';

  @override
  String get common_delete => 'Supprimer';

  @override
  String get common_edit => 'Modifier';

  @override
  String get common_back => 'Retour';

  @override
  String get common_retry => 'Réessayer';

  @override
  String get common_loading => 'Chargement...';

  @override
  String get common_error => 'Une erreur est survenue';

  @override
  String get common_empty => 'Aucun élément à afficher';

  @override
  String get common_search => 'Rechercher';

  @override
  String get common_confirm => 'Confirmer';

  @override
  String get auth_login => 'Connexion';

  @override
  String get auth_logout => 'Déconnexion';

  @override
  String get auth_register => 'Créer un compte';

  @override
  String get auth_email => 'Adresse e-mail';

  @override
  String get auth_password => 'Mot de passe';

  @override
  String get auth_forgot_password => 'Mot de passe oublié ?';

  @override
  String get auth_no_account => 'Pas encore de compte ?';

  @override
  String get auth_already_account => 'Déjà un compte ?';

  @override
  String get errors_network =>
      'Pas de connexion internet. Vérifiez votre réseau.';

  @override
  String get errors_server => 'Erreur serveur. Veuillez réessayer plus tard.';

  @override
  String get errors_unknown => 'Une erreur inattendue est survenue.';

  @override
  String get errors_validation => 'Veuillez vérifier les informations saisies.';

  @override
  String get errors_session_expired =>
      'Session expirée. Veuillez vous reconnecter.';

  @override
  String get navigation_home => 'Accueil';

  @override
  String get navigation_profile => 'Profil';

  @override
  String get navigation_settings => 'Paramètres';

  @override
  String get navigation_notifications => 'Notifications';

  @override
  String get example_title => 'Exemples';

  @override
  String get example_empty => 'Aucun exemple disponible.';

  @override
  String get example_detail => 'Détail';

  @override
  String example_created_at(String date) {
    return 'Créé le $date';
  }
}
