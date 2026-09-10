import 'package:chopper/chopper.dart';
import 'package:motodi_go_mobile/core/config/app_config.dart';
import 'package:motodi_go_mobile/core/network/interceptors.dart';
import 'package:motodi_go_mobile/core/network/authenticator.dart';
import 'package:motodi_go_mobile/core/network/json_type_converter.dart';

// Rôle : Configure le ChopperClient central avec intercepteurs, auth et convertisseurs JSON.
// Dépendances : chopper, app_config, interceptors.dart, authenticator.dart
// Désactiver : remplacer ChopperClient par Dio ou http selon vos besoins.
class AppApiClient {
  // TODO: [TEMPLATE] Renommer 'AppApiClient' selon votre projet
  static ChopperClient create() {
    final baseUrl = AppConfig.apiBaseUrl;

    return ChopperClient(
      baseUrl: Uri.parse(baseUrl),
      interceptors: [AuthInterceptor(), HttpLoggingInterceptor()],
      authenticator: AppAuthenticator(),
      converter: const JsonToTypeConverter({
        // TODO: [TEMPLATE] Enregistrer ici vos modèles de réponse JSON
        // ExampleModel: (json) => ExampleModel.fromJson(json),
      }),
      errorConverter: const JsonToTypeConverter({}),
    );
  }
}
