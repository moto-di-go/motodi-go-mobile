import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/core/network/network_info.dart';
import 'package:motodi_go_mobile/features/auth/data/models/api_error_model.dart';
import 'package:motodi_go_mobile/features/offline/domain/entities/offline_entities.dart';
import 'package:motodi_go_mobile/features/offline/domain/repositories/offline_repository.dart';
import 'package:motodi_go_mobile/features/profiles/data/datasources/profile_remote_datasource.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_input.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/user_profile.dart';
import 'package:motodi_go_mobile/features/profiles/domain/repositories/profile_repository.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  final OfflineRepository _offlineRepository;

  ProfileRepositoryImpl(this._remoteDataSource, this._networkInfo, this._offlineRepository);

  @override
  Future<Either<Failure, List<UserProfile>>> listProfiles() async {
    if (!await _networkInfo.isConnected) {
      return left(const NetworkFailure('Pas de connexion internet.', code: 'NETWORK_OFFLINE'));
    }
    try {
      final profiles = await _remoteDataSource.listProfiles();
      return right(
        profiles
            .map((profile) => profile.toEntity())
            .where((profile) => profile.canBeShownInMobile)
            .toList(),
      );
    } catch (e) {
      return left(_failureFromException(e));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> currentProfile() async {
    if (!await _networkInfo.isConnected) {
      return left(const NetworkFailure('Pas de connexion internet.', code: 'NETWORK_OFFLINE'));
    }
    try {
      final profile = await _remoteDataSource.currentProfile();
      return right(profile.toEntity());
    } catch (e) {
      return left(_failureFromException(e));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> createProfile(ProfileInput input) async {
    if (!input.type.isSelfService) {
      return left(
        const ValidationFailure('Type de profil non pris en charge.', code: 'PROFILE_NOT_ALLOWED'),
      );
    }
    if (!await _networkInfo.isConnected) {
      return left(const NetworkFailure('Pas de connexion internet.', code: 'NETWORK_OFFLINE'));
    }
    try {
      final profile = await _remoteDataSource.createProfile(input);
      return right(profile.toEntity());
    } catch (e) {
      return left(_failureFromException(e));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile(String profileId, ProfileInput input) async {
    if (!await _networkInfo.isConnected) {
      await _offlineRepository.enqueue(
        type: OfflineOperationType.profileUpdate,
        payload: {
          'profileId': profileId,
          'type': input.type.name,
          'displayName': input.displayName,
          if (input.preferredLanguage != null) 'preferredLanguage': input.preferredLanguage,
          if (input.emergencyContact != null) 'emergencyContact': input.emergencyContact,
          if (input.licenseNumber != null) 'licenseNumber': input.licenseNumber,
          if (input.operatingZone != null) 'operatingZone': input.operatingZone,
          if (input.companyName != null) 'companyName': input.companyName,
          if (input.permitNumber != null) 'permitNumber': input.permitNumber,
        },
      );
      return left(
        const NetworkFailure(
          'Modification enregistrée sur ce téléphone. Elle sera synchronisée plus tard.',
          code: 'OFFLINE_QUEUED',
        ),
      );
    }
    try {
      final profile = await _remoteDataSource.updateProfile(profileId, input);
      return right(profile.toEntity());
    } catch (e) {
      return left(_failureFromException(e));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> activateProfile(String profileId) async {
    if (!await _networkInfo.isConnected) {
      return left(const NetworkFailure('Pas de connexion internet.', code: 'NETWORK_OFFLINE'));
    }
    try {
      final profile = await _remoteDataSource.activateProfile(profileId);
      return right(profile.toEntity());
    } catch (e) {
      return left(_failureFromException(e));
    }
  }

  Failure _failureFromException(Object error) {
    if (error is ApiException) {
      return switch (error.code) {
        'PROFILE_RULE_VIOLATION' ||
        'PROFILE_ALREADY_EXISTS' ||
        'VALIDATION_FAILED' => ValidationFailure(error.message, code: error.code),
        'PROFILE_NOT_ALLOWED' => AuthFailure(error.message, code: error.code),
        'SESSION_EXPIRED' => AuthFailure(error.message, code: error.code),
        _ => ServerFailure(error.message, code: error.code),
      };
    }
    return ServerFailure(error.toString());
  }
}
