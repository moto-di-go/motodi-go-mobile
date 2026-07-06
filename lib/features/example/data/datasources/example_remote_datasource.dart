import 'package:injectable/injectable.dart';
import 'package:flutter_template_app/features/example/data/models/example_model.dart';

// Rôle : Source de données distante — appels API via Chopper.
// TODO: [TEMPLATE] Injecter votre ChopperService ici et réaliser les vrais appels API.
@lazySingleton
class ExampleRemoteDataSource {
  // TODO: [TEMPLATE] Remplacer par ExampleApiService (Chopper)
  // final ExampleApiService _apiService;
  // ExampleRemoteDataSource(this._apiService);

  // Données factices pour le template — à supprimer en production
  Future<List<ExampleModel>> getExamples() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      ExampleModel(
        id: '1',
        title: 'Exemple A',
        description: 'Description de l\'exemple A',
        createdAt: DateTime.now(),
      ),
      ExampleModel(
        id: '2',
        title: 'Exemple B',
        description: 'Description de l\'exemple B',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ExampleModel(
        id: '3',
        title: 'Exemple C',
        description: 'Description de l\'exemple C',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  Future<ExampleModel> getExampleById(String id) async {
    final all = await getExamples();
    return all.firstWhere((e) => e.id == id);
  }

  Future<ExampleModel> createExample({required String title, required String description}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ExampleModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );
  }
}
