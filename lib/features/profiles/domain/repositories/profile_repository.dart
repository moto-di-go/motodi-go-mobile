import 'package:fpdart/fpdart.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_input.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, List<UserProfile>>> listProfiles();
  Future<Either<Failure, UserProfile>> currentProfile();
  Future<Either<Failure, UserProfile>> createProfile(ProfileInput input);
  Future<Either<Failure, UserProfile>> updateProfile(String profileId, ProfileInput input);
  Future<Either<Failure, UserProfile>> activateProfile(String profileId);
}
