import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_template_app/core/error/failure.dart';

void main() {
  group('Failure', () {
    group('ServerFailure', () {
      test('should have correct message and null code by default', () {
        const failure = ServerFailure('Erreur serveur');
        expect(failure.message, 'Erreur serveur');
        expect(failure.code, isNull);
      });

      test('should support optional error code', () {
        const failure = ServerFailure('Erreur', code: '404');
        expect(failure.code, '404');
      });

      test('should be equal when message and code are identical', () {
        const f1 = ServerFailure('msg', code: '500');
        const f2 = ServerFailure('msg', code: '500');
        expect(f1, equals(f2));
      });

      test('should NOT be equal when message differs', () {
        const f1 = ServerFailure('msg1');
        const f2 = ServerFailure('msg2');
        expect(f1, isNot(equals(f2)));
      });
    });

    group('NetworkFailure', () {
      test('should have correct message', () {
        const failure = NetworkFailure('Pas de réseau');
        expect(failure.message, 'Pas de réseau');
      });

      test('should be different type from ServerFailure', () {
        const network = NetworkFailure('error');
        const server = ServerFailure('error');
        expect(network, isNot(equals(server)));
      });
    });

    group('CacheFailure', () {
      test('should have correct message', () {
        const failure = CacheFailure('Cache corrompu');
        expect(failure.message, 'Cache corrompu');
      });
    });

    group('ValidationFailure', () {
      test('should have correct message and code', () {
        const failure = ValidationFailure('Champ requis', code: 'REQUIRED');
        expect(failure.message, 'Champ requis');
        expect(failure.code, 'REQUIRED');
      });
    });

    group('AuthFailure', () {
      test('should have correct message', () {
        const failure = AuthFailure('Non autorisé', code: 'UNAUTHORIZED');
        expect(failure.message, 'Non autorisé');
        expect(failure.code, 'UNAUTHORIZED');
      });
    });
  });
}
