import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// Test d'intégration (smoke test) — exécuter avec un émulateur/appareil :
//   flutter test integration_test/ --dart-define=APP_ENV=development
//
// Pour tester le vrai démarrage de l'app, décommenter et configurer :
//   1. Créer un .env valide (make set-env)
//   2. Configurer Firebase (flutterfire configure)
//   3. Importer et appeler app.main() ci-dessous
// import 'package:flutter_template_app/main.dart' as app;
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Smoke tests', () {
    testWidgets('le framework Flutter est opérationnel', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: Text('Flutter Template — OK'))),
        ),
      );

      expect(find.text('Flutter Template — OK'), findsOneWidget);
    });

    testWidgets('les widgets Material de base fonctionnent', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')),
            body: ElevatedButton(onPressed: () {}, child: const Text('Bouton')),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Bouton'), findsOneWidget);
    });
  });
}
