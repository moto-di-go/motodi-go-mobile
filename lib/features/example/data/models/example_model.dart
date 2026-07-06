import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_template_app/features/example/domain/entities/example_entity.dart';

part 'example_model.g.dart';

// Rôle : Modèle de données — mappe le JSON API vers une entité du domaine.
// Génération : dart run build_runner build
@JsonSerializable()
class ExampleModel {
  final String id;
  final String title;
  final String description;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const ExampleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory ExampleModel.fromJson(Map<String, dynamic> json) => _$ExampleModelFromJson(json);
  Map<String, dynamic> toJson() => _$ExampleModelToJson(this);

  ExampleEntity toEntity() =>
      ExampleEntity(id: id, title: title, description: description, createdAt: createdAt);

  static ExampleModel fromEntity(ExampleEntity entity) => ExampleModel(
    id: entity.id,
    title: entity.title,
    description: entity.description,
    createdAt: entity.createdAt,
  );
}
