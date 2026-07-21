import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_input.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/user_profile.dart';
import 'package:motodi_go_mobile/features/profiles/domain/repositories/profile_repository.dart';

part 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileCubit(this._profileRepository) : super(const ProfileState());

  Future<void> loadProfiles() async {
    emit(state.copyWith(status: ProfileStatus.loading, errorMessage: null));
    final result = await _profileRepository.listProfiles();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: failure.message,
          errorCode: failure.code,
        ),
      ),
      (profiles) => emit(state.copyWith(status: ProfileStatus.success, profiles: profiles)),
    );
  }

  void selectType(ProfileType type) {
    emit(state.copyWith(selectedType: type, errorMessage: null));
  }

  Future<void> createPassenger({
    required String displayName,
    required String preferredLanguage,
    String? emergencyContact,
  }) {
    return _create(
      ProfileInput(
        type: ProfileType.passenger,
        displayName: displayName.trim(),
        preferredLanguage: preferredLanguage,
        emergencyContact: emergencyContact,
      ),
    );
  }

  Future<void> createMotoTaxi({
    required String displayName,
    required String operatingZone,
    String? licenseNumber,
  }) {
    return _create(
      ProfileInput(
        type: ProfileType.mototaxi,
        displayName: displayName.trim(),
        operatingZone: operatingZone.trim(),
        licenseNumber: licenseNumber,
      ),
    );
  }

  Future<void> createTransporter({required String companyName, String? permitNumber}) {
    return _create(
      ProfileInput(
        type: ProfileType.transporter,
        displayName: companyName.trim(),
        companyName: companyName.trim(),
        permitNumber: permitNumber,
      ),
    );
  }

  Future<void> activateProfile(String profileId) async {
    emit(state.copyWith(status: ProfileStatus.saving, errorMessage: null));
    final result = await _profileRepository.activateProfile(profileId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: failure.message,
          errorCode: failure.code,
        ),
      ),
      (profile) => emit(
        state.copyWith(
          status: ProfileStatus.saved,
          savedProfile: profile,
          profiles: state.profiles
              .map(
                (item) => item.id == profile.id
                    ? profile
                    : UserProfile(
                        id: item.id,
                        userId: item.userId,
                        type: item.type,
                        validationStatus: item.validationStatus,
                        displayName: item.displayName,
                        avatarUrl: item.avatarUrl,
                        averageRating: item.averageRating,
                        active: false,
                        createdAt: item.createdAt,
                        updatedAt: item.updatedAt,
                        passenger: item.passenger,
                        driver: item.driver,
                        motoTaxi: item.motoTaxi,
                        transporter: item.transporter,
                        agency: item.agency,
                        allowedActions: item.allowedActions,
                      ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _create(ProfileInput input) async {
    if (input.displayName.trim().isEmpty) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: 'Le nom affiché est requis.',
          errorCode: 'DISPLAY_NAME_REQUIRED',
        ),
      );
      return;
    }
    emit(state.copyWith(status: ProfileStatus.saving, errorMessage: null));
    final result = await _profileRepository.createProfile(input);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: failure.message,
          errorCode: failure.code,
        ),
      ),
      (profile) => emit(
        state.copyWith(
          status: ProfileStatus.saved,
          savedProfile: profile,
          profiles: [...state.profiles.where((item) => item.id != profile.id), profile],
        ),
      ),
    );
  }
}
