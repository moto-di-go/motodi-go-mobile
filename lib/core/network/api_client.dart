import 'package:chopper/chopper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_template_app/core/network/interceptors.dart';
import 'package:flutter_template_app/core/network/authenticator.dart';
import 'package:flutter_template_app/core/network/json_type_converter.dart';

// Rôle : Configure le ChopperClient central avec intercepteurs, auth et convertisseurs JSON.
// Dépendances : chopper, flutter_dotenv, interceptors.dart, authenticator.dart
// Désactiver : remplacer ChopperClient par Dio ou http selon vos besoins.
class AppApiClient {
  // TODO: [TEMPLATE] Renommer 'AppApiClient' selon votre projet
  static ChopperClient create() {
    // TODO: [TEMPLATE] Adapter la clé .env si nécessaire
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://api.yourapp.com/api/v1';

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
