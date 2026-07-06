import 'package:chopper/chopper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:flutter_template_app/core/network/api_client.dart';

// Rôle : Enregistre les dépendances tierces (non-injectable) dans GetIt.
// TODO: [TEMPLATE] Ajouter ici vos services Chopper pour chaque feature.
@module
abstract class RegisterModule {
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  ChopperClient get chopperClient => AppApiClient.create();

  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @lazySingleton
  Logger get logger => Logger();

  @lazySingleton
  InternetConnectionChecker get connectionChecker => InternetConnectionChecker.createInstance();
}
