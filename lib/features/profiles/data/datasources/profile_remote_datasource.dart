import 'package:chopper/chopper.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/auth/data/models/api_error_model.dart';
import 'package:motodi_go_mobile/features/profiles/data/models/profile_model.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_input.dart';

abstract class ProfileRemoteDataSource {
  Future<List<ProfileModel>> listProfiles();
  Future<ProfileModel> currentProfile();
  Future<ProfileModel> createProfile(ProfileInput input);
  Future<ProfileModel> updateProfile(String profileId, ProfileInput input);
  Future<ProfileModel> activateProfile(String profileId);
}

@LazySingleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ChopperClient _client;

  ProfileRemoteDataSourceImpl(this._client);

  @override
  Future<List<ProfileModel>> listProfiles() async {
    final response = await _client.get<List<dynamic>, Map<String, dynamic>>(Uri.parse('/profiles'));
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return (response.body ?? [])
        .map((value) => ProfileModel.fromJson(Map<String, dynamic>.from(value as Map)))
        .toList();
  }

  @override
  Future<ProfileModel> currentProfile() async {
    final response = await _client.get<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/profiles/current'),
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return ProfileModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<ProfileModel> createProfile(ProfileInput input) async {
    final response = await _client.post<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/profiles'),
      body: ProfilePayload.fromInput(input).toCreateJson(),
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return ProfileModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<ProfileModel> updateProfile(String profileId, ProfileInput input) async {
    final response = await _client.patch<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/profiles/$profileId'),
      body: ProfilePayload.fromInput(input).toCreateJson()..remove('type'),
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return ProfileModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<ProfileModel> activateProfile(String profileId) async {
    final response = await _client.patch<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/profiles/active/$profileId'),
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return ProfileModel.fromJson(response.body ?? <String, dynamic>{});
  }
}
