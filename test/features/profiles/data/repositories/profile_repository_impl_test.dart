import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/core/network/network_info.dart';
import 'package:motodi_go_mobile/features/profiles/data/datasources/profile_remote_datasource.dart';
import 'package:motodi_go_mobile/features/profiles/data/models/profile_model.dart';
import 'package:motodi_go_mobile/features/profiles/data/repositories/profile_repository_impl.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_input.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';

class MockProfileRemoteDataSource extends Mock implements ProfileRemoteDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockProfileRemoteDataSource remote;
  late MockNetworkInfo network;
  late ProfileRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const ProfileInput(type: ProfileType.passenger, displayName: 'fallback'));
  });

  setUp(() {
    remote = MockProfileRemoteDataSource();
    network = MockNetworkInfo();
    repository = ProfileRepositoryImpl(remote, network);
  });

  group('listProfiles', () {
    test('filters agency/admin profiles from the mobile UI surface', () async {
      when(() => network.isConnected).thenAnswer((_) async => true);
      when(() => remote.listProfiles()).thenAnswer(
        (_) async => [
          _profile('passenger-1', ProfileType.passenger, ValidationStatus.validated),
          _profile('agency-1', ProfileType.agency, ValidationStatus.pending),
          _profile('mototaxi-1', ProfileType.mototaxi, ValidationStatus.pending),
        ],
      );

      final result = await repository.listProfiles();

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('no failure'), (profiles) {
        expect(profiles.map((profile) => profile.type), [
          ProfileType.passenger,
          ProfileType.mototaxi,
        ]);
      });
    });

    test('returns NetworkFailure when offline', () async {
      when(() => network.isConnected).thenAnswer((_) async => false);

      final result = await repository.listProfiles();

      expect(result.isLeft(), isTrue);
      result.fold((failure) => expect(failure, isA<NetworkFailure>()), (_) => fail('no data'));
      verifyNever(() => remote.listProfiles());
    });
  });

  group('createProfile', () {
    test('rejects agency profile creation locally', () async {
      final result = await repository.createProfile(
        const ProfileInput(type: ProfileType.agency, displayName: 'Agence'),
      );

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.code, 'PROFILE_NOT_ALLOWED');
      }, (_) => fail('no data'));
      verifyNever(() => network.isConnected);
      verifyNever(() => remote.createProfile(any()));
    });

    test('creates supported mototaxi profile when online', () async {
      const input = ProfileInput(
        type: ProfileType.mototaxi,
        displayName: 'Ibrahim M.',
        operatingZone: 'Bastos',
      );
      when(() => network.isConnected).thenAnswer((_) async => true);
      when(() => remote.createProfile(input)).thenAnswer(
        (_) async => _profile('mototaxi-1', ProfileType.mototaxi, ValidationStatus.pending),
      );

      final result = await repository.createProfile(input);

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('no failure'), (profile) {
        expect(profile.type, ProfileType.mototaxi);
        expect(profile.validationStatus, ValidationStatus.pending);
      });
    });
  });

  group('activateProfile', () {
    test('delegates activation to remote datasource', () async {
      when(() => network.isConnected).thenAnswer((_) async => true);
      when(() => remote.activateProfile('passenger-1')).thenAnswer(
        (_) async => _profile(
          'passenger-1',
          ProfileType.passenger,
          ValidationStatus.validated,
          active: true,
        ),
      );

      final result = await repository.activateProfile('passenger-1');

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('no failure'), (profile) => expect(profile.active, isTrue));
    });
  });
}

ProfileModel _profile(String id, ProfileType type, ValidationStatus status, {bool active = false}) {
  return ProfileModel(
    id: id,
    userId: 'user-1',
    type: type,
    validationStatus: status,
    displayName: id,
    averageRating: 0,
    active: active,
    allowedActions: const [],
  );
}
