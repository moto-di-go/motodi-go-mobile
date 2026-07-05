import 'dart:async';
import 'package:chopper/chopper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Rôle : Rafraîchit le token JWT automatiquement lors d'une erreur 401.
// Dépendances : chopper, flutter_secure_storage
// TODO: [TEMPLATE] Implémenter la logique de refresh selon votre API
class AppAuthenticator extends Authenticator {
  final _storage = const FlutterSecureStorage();

  @override
  FutureOr<Request?> authenticate(
    Request request,
    Response response, [
    Request? originalRequest,
  ]) async {
    if (response.statusCode == 401) {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return null;

      // TODO: [TEMPLATE] Appeler votre endpoint de refresh ici
      // Exemple : final newToken = await _refreshTokenFromApi(refreshToken);
      // if (newToken != null) {
      //   await _storage.write(key: 'access_token', value: newToken);
      //   return applyHeader(request, 'Authorization', 'Bearer $newToken');
      // }
    }
    return null;
  }
}
