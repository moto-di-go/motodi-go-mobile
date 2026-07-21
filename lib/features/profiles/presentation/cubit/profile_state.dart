part of 'profile_cubit.dart';

enum ProfileStatus { initial, loading, success, saving, saved, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final List<UserProfile> profiles;
  final ProfileType selectedType;
  final UserProfile? savedProfile;
  final String? errorMessage;
  final String? errorCode;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profiles = const [],
    this.selectedType = ProfileType.passenger,
    this.savedProfile,
    this.errorMessage,
    this.errorCode,
  });

  bool get isLoading => status == ProfileStatus.loading || status == ProfileStatus.saving;
  bool get isSaved => status == ProfileStatus.saved;
  bool get hasProfiles => profiles.isNotEmpty;

  ProfileState copyWith({
    ProfileStatus? status,
    List<UserProfile>? profiles,
    ProfileType? selectedType,
    UserProfile? savedProfile,
    String? errorMessage,
    String? errorCode,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profiles: profiles ?? this.profiles,
      selectedType: selectedType ?? this.selectedType,
      savedProfile: savedProfile ?? this.savedProfile,
      errorMessage: errorMessage,
      errorCode: errorCode,
    );
  }

  @override
  List<Object?> get props => [
    status,
    profiles,
    selectedType,
    savedProfile,
    errorMessage,
    errorCode,
  ];
}
