import 'dart:async';
import 'package:chopper/chopper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Rôle : Intercepteurs Chopper — injection du token JWT et logging.
// Dépendances : chopper, flutter_secure_storage
class AuthInterceptor implements Interceptor {
  final _storage = const FlutterSecureStorage();

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      final request = applyHeader(chain.request, 'Authorization', 'Bearer $token');
      return chain.proceed(request);
    }
    return chain.proceed(chain.request);
  }
}
