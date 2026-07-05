import 'dart:convert';
import 'package:chopper/chopper.dart';

// Rôle : Convertit les réponses JSON Chopper en instances de modèles Dart.
// Usage : Enregistrer vos modèles dans la Map passée au constructeur.
typedef JsonFactory<T> = T Function(Map<String, dynamic> json);

class JsonToTypeConverter extends JsonConverter {
  final Map<Type, JsonFactory> factories;

  const JsonToTypeConverter(this.factories);

  @override
  Response<BodyType> convertResponse<BodyType, InnerType>(Response response) {
    return response.copyWith<BodyType>(
      body: fromJsonData<BodyType, InnerType>(response.body, factories[InnerType]),
    );
  }

  T? fromJsonData<T, InnerType>(String? data, JsonFactory? factory) {
    if (data == null) return null;
    final jsonData = json.decode(data);
    if (factory != null) {
      if (jsonData is List) {
        return jsonData.map((e) => factory(e as Map<String, dynamic>)).toList() as T;
      }
      return factory(jsonData as Map<String, dynamic>) as T;
    }
    return jsonData as T;
  }
}
