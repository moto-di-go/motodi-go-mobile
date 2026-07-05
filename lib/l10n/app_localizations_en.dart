// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Flutter Template App';

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
  String get errors_network =>
      'No internet connection. Please check your network.';

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
}
