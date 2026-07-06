import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter_template_app/core/network/network_info.dart';

class MockInternetConnectionChecker extends Mock implements InternetConnectionChecker {}

void main() {
  late NetworkInfoImpl networkInfo;
  late MockInternetConnectionChecker mockChecker;

  setUp(() {
    mockChecker = MockInternetConnectionChecker();
    networkInfo = NetworkInfoImpl(mockChecker);
  });

  group('NetworkInfo', () {
    test('should return true when device is connected', () async {
      when(() => mockChecker.hasConnection).thenAnswer((_) async => true);
      final result = await networkInfo.isConnected;
      expect(result, isTrue);
      verify(() => mockChecker.hasConnection).called(1);
    });

    test('should return false when device is not connected', () async {
      when(() => mockChecker.hasConnection).thenAnswer((_) async => false);
      final result = await networkInfo.isConnected;
      expect(result, isFalse);
    });
  });
}
