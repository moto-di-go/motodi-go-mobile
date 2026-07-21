import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_input.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/user_profile.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';
import 'package:motodi_go_mobile/features/profiles/domain/repositories/profile_repository.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/cubit/profile_cubit.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockProfileRepository repository;

  setUpAll(() {
    registerFallbackValue(const ProfileInput(type: ProfileType.passenger, displayName: 'fallback'));
  });

  setUp(() {
    repository = MockProfileRepository();
  });

  blocTest<ProfileCubit, ProfileState>(
    'loadProfiles emits loaded profiles',
    build: () {
      when(() => repository.listProfiles()).thenAnswer(
        (_) async => right([_profile('passenger-1', ProfileType.passenger, active: true)]),
      );
      return ProfileCubit(repository);
    },
    act: (cubit) => cubit.loadProfiles(),
    expect: () => [
      const ProfileState(status: ProfileStatus.loading),
      ProfileState(
        status: ProfileStatus.success,
        profiles: [_profile('passenger-1', ProfileType.passenger, active: true)],
      ),
    ],
  );

  blocTest<ProfileCubit, ProfileState>(
    'createPassenger validates display name locally',
    build: () => ProfileCubit(repository),
    act: (cubit) => cubit.createPassenger(displayName: ' ', preferredLanguage: 'fr'),
    expect: () => [
      isA<ProfileState>()
          .having((state) => state.status, 'status', ProfileStatus.failure)
          .having((state) => state.errorCode, 'errorCode', 'DISPLAY_NAME_REQUIRED'),
    ],
    verify: (_) => verifyNever(() => repository.createProfile(any())),
  );

  blocTest<ProfileCubit, ProfileState>(
    'createMotoTaxi sends pending driver profile input',
    build: () {
      when(
        () => repository.createProfile(any()),
      ).thenAnswer((_) async => right(_profile('mototaxi-1', ProfileType.mototaxi)));
      return ProfileCubit(repository);
    },
    act: (cubit) => cubit.createMotoTaxi(
      displayName: 'Ibrahim M.',
      operatingZone: 'Bastos, Yaounde',
      licenseNumber: 'CM-YDE-000001',
    ),
    expect: () => [
      const ProfileState(status: ProfileStatus.saving),
      ProfileState(
        status: ProfileStatus.saved,
        profiles: [_profile('mototaxi-1', ProfileType.mototaxi)],
        savedProfile: _profile('mototaxi-1', ProfileType.mototaxi),
      ),
    ],
    verify: (_) {
      final input =
          verify(() => repository.createProfile(captureAny())).captured.single as ProfileInput;
      expect(input.type, ProfileType.mototaxi);
      expect(input.displayName, 'Ibrahim M.');
      expect(input.operatingZone, 'Bastos, Yaounde');
      expect(input.licenseNumber, 'CM-YDE-000001');
    },
  );

  blocTest<ProfileCubit, ProfileState>(
    'activateProfile marks the returned profile active and clears previous active state',
    seed: () => ProfileState(
      status: ProfileStatus.success,
      profiles: [
        _profile('passenger-1', ProfileType.passenger, active: true),
        _profile('mototaxi-1', ProfileType.mototaxi),
      ],
    ),
    build: () {
      when(
        () => repository.activateProfile('mototaxi-1'),
      ).thenAnswer((_) async => right(_profile('mototaxi-1', ProfileType.mototaxi, active: true)));
      return ProfileCubit(repository);
    },
    act: (cubit) => cubit.activateProfile('mototaxi-1'),
    expect: () => [
      ProfileState(
        status: ProfileStatus.saving,
        profiles: [
          _profile('passenger-1', ProfileType.passenger, active: true),
          _profile('mototaxi-1', ProfileType.mototaxi),
        ],
      ),
      ProfileState(
        status: ProfileStatus.saved,
        savedProfile: _profile('mototaxi-1', ProfileType.mototaxi, active: true),
        profiles: [
          _profile('passenger-1', ProfileType.passenger),
          _profile('mototaxi-1', ProfileType.mototaxi, active: true),
        ],
      ),
    ],
  );

  blocTest<ProfileCubit, ProfileState>(
    'loadProfiles maps repository failures',
    build: () {
      when(
        () => repository.listProfiles(),
      ).thenAnswer((_) async => left(const NetworkFailure('Offline', code: 'NETWORK_OFFLINE')));
      return ProfileCubit(repository);
    },
    act: (cubit) => cubit.loadProfiles(),
    expect: () => [
      const ProfileState(status: ProfileStatus.loading),
      const ProfileState(
        status: ProfileStatus.failure,
        errorMessage: 'Offline',
        errorCode: 'NETWORK_OFFLINE',
      ),
    ],
  );
}

UserProfile _profile(String id, ProfileType type, {bool active = false}) {
  return UserProfile(
    id: id,
    userId: 'user-1',
    type: type,
    validationStatus: type == ProfileType.passenger
        ? ValidationStatus.validated
        : ValidationStatus.pending,
    displayName: id,
    averageRating: 0,
    active: active,
    allowedActions: const [],
  );
}
