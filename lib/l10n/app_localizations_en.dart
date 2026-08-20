// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Moto\'di Go';

  @override
  String get common_ok => 'OK';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_save => 'Save';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_back => 'Back';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_loading => 'Loading...';

  @override
  String get common_error => 'An error occurred';

  @override
  String get common_empty => 'Nothing to display';

  @override
  String get common_search => 'Search';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get auth_login => 'Sign In';

  @override
  String get auth_logout => 'Sign Out';

  @override
  String get auth_register => 'Create Account';

  @override
  String get auth_email => 'Email address';

  @override
  String get auth_password => 'Password';

  @override
  String get auth_forgot_password => 'Forgot password?';

  @override
  String get auth_no_account => 'Don\'t have an account?';

  @override
  String get auth_already_account => 'Already have an account?';

  @override
  String get errors_network => 'No internet connection. Please check your network.';

  @override
  String get errors_server => 'Server error. Please try again later.';

  @override
  String get errors_unknown => 'An unexpected error occurred.';

  @override
  String get errors_validation => 'Please check the information provided.';

  @override
  String get errors_session_expired => 'Session expired. Please sign in again.';

  @override
  String get navigation_home => 'Home';

  @override
  String get navigation_profile => 'Profile';

  @override
  String get navigation_settings => 'Settings';

  @override
  String get navigation_notifications => 'Notifications';

  @override
  String get example_title => 'Examples';

  @override
  String get example_empty => 'No examples available.';

  @override
  String get example_detail => 'Detail';

  @override
  String example_created_at(String date) {
    return 'Created on $date';
  }

  @override
  String get passenger_profile_title => 'Passenger profile';

  @override
  String get passenger_profile_description =>
      'A few preferences to finalize your passenger profile.';

  @override
  String get passenger_profile_language_label => 'Preferred language';

  @override
  String get passenger_profile_language_fr => 'French';

  @override
  String get passenger_profile_language_en => 'English';

  @override
  String get passenger_profile_emergency_label => 'Emergency contact';

  @override
  String get passenger_profile_optional => 'optional';

  @override
  String get passenger_profile_emergency_hint => 'A relative\'s number';

  @override
  String get passenger_profile_submit => 'Finish';

  @override
  String get mototaxiProfileTitle => 'Mototaxi profile';

  @override
  String get mototaxiProfileWarning =>
      'Validation required: your documents will be checked before activation.';

  @override
  String get mototaxiProfileDisplayNameLabel => 'Display name';

  @override
  String get mototaxiProfileDisplayNameHint => 'Ibrahim M.';

  @override
  String get mototaxiProfileZoneLabel => 'Operating area';

  @override
  String get mototaxiProfileLicenseLabel => 'License number';

  @override
  String get mototaxiProfileLicenseOptional => 'if available';

  @override
  String get mototaxiProfileLicenseHint => 'CM-YDE-000000';

  @override
  String get mototaxiProfileSubmit => 'Continue to validation';

  @override
  String get transporterProfileTitle => 'Transporter profile';

  @override
  String get transporterProfileWarning =>
      'Permit and vehicle documents are required for validation.';

  @override
  String get transporterProfileCompanyNameLabel => 'Business name';

  @override
  String get transporterProfileCompanyNameHint => 'Express Voyages SARL';

  @override
  String get transporterProfilePermitLabel => 'Permit / license number';

  @override
  String get transporterProfilePermitHint => 'Ex. AGR-2024-01234';

  @override
  String get transporterProfileVehicleLabel => 'Vehicle';

  @override
  String get transporterProfileVehicleKycText =>
      'Add your vehicle photo in KYC verification. Without this document, your profile stays pending validation.';

  @override
  String get transporterProfileVehicleSoon => 'Required';

  @override
  String get transporterProfileSubmit => 'Continue to validation';

  @override
  String get profileSwitcherTitle => 'Switch profile';

  @override
  String get profileSwitcherSubtitle => 'One active profile at a time.';

  @override
  String get profileSwitcherAddProfile => 'Add a profile';
}
