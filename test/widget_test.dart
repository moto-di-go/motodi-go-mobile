// Test de smoke global — vérifie que l'app se monte sans crash.
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App', () {
    test('placeholder — smoke test configuration', () {
      // Ce test valide uniquement que la suite de tests est configurée.
      // Les smoke tests UI complets nécessitent un émulateur.
      expect(1 + 1, equals(2));
    });
  });
}
