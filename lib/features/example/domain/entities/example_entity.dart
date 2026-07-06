import 'package:equatable/equatable.dart';

// Rôle : Entité du domaine — objet métier pur, sans dépendance à la couche data.
// TODO: [TEMPLATE] Remplacer par vos propres entités métier.
class ExampleEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;

  const ExampleEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, description, createdAt];
}
