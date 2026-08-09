// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Moto\'di Go';

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

  @override
  String get passenger_profile_title => 'Profil passager';

  @override
  String get passenger_profile_description =>
      'Quelques préférences pour finaliser votre profil passager.';

  @override
  String get passenger_profile_language_label => 'Langue préférée';

  @override
  String get passenger_profile_language_fr => 'Français';

  @override
  String get passenger_profile_language_en => 'Anglais';

  @override
  String get passenger_profile_emergency_label => 'Contact d\'urgence';

  @override
  String get passenger_profile_optional => 'optionnel';

  @override
  String get passenger_profile_emergency_hint => 'Numéro d\'un proche';

  @override
  String get passenger_profile_submit => 'Terminer';

  @override
  String get mototaxiProfileTitle => 'Profil mototaxi';

  @override
  String get mototaxiProfileWarning =>
      'Validation obligatoire : vos documents seront vérifiés avant l\'activation.';

  @override
  String get mototaxiProfileDisplayNameLabel => 'Nom affiché';

  @override
  String get mototaxiProfileDisplayNameHint => 'Ibrahim M.';

  @override
  String get mototaxiProfileZoneLabel => 'Zone d\'activité';

  @override
  String get mototaxiProfileLicenseLabel => 'N° de permis';

  @override
  String get mototaxiProfileLicenseOptional => 'si disponible';

  @override
  String get mototaxiProfileLicenseHint => 'CM-YDE-000000';

  @override
  String get mototaxiProfileSubmit => 'Continuer vers la validation';

  @override
  String get transporterProfileTitle => 'Profil transporteur';

  @override
  String get transporterProfileWarning =>
      'Agrément et documents véhicule requis pour la validation.';

  @override
  String get transporterProfileCompanyNameLabel => 'Nom commercial';

  @override
  String get transporterProfileCompanyNameHint => 'Express Voyages SARL';

  @override
  String get transporterProfilePermitLabel => 'N° d\'agrément / permis';

  @override
  String get transporterProfilePermitHint => 'Ex. AGR-2024-01234';

  @override
  String get transporterProfileVehicleLabel => 'Véhicule';

  @override
  String get transporterProfileVehicleKycText =>
      'Ajoutez la photo de votre véhicule dans la vérification KYC. Sans ce document, votre profil reste en attente de validation.';

  @override
  String get transporterProfileVehicleSoon => 'Requis';

  @override
  String get transporterProfileSubmit => 'Continuer vers la validation';

  @override
  String get profileSwitcherTitle => 'Changer de profil';

  @override
  String get profileSwitcherSubtitle => 'Un profil actif à la fois.';

  @override
  String get profileSwitcherAddProfile => 'Ajouter un profil';
}
