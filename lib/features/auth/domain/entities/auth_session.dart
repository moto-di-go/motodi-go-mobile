import 'package:equatable/equatable.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_summary.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';

class AuthSession extends Equatable {
  final String tokenType;
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiresAt;
  final DateTime refreshTokenExpiresAt;
  final String sessionId;
  final String userId;
  final String phoneNumber;
  final List<ProfileType> roles;
  final List<ProfileSummary> profiles;
  final String? activeProfileId;
  final ProfileType? activeProfileType;
  final List<String> permissions;

  const AuthSession({
    required this.tokenType,
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
    required this.refreshTokenExpiresAt,
    required this.sessionId,
    required this.userId,
    required this.phoneNumber,
    required this.roles,
    required this.profiles,
    this.activeProfileId,
    this.activeProfileType,
    required this.permissions,
  });

  bool get hasActiveProfile => activeProfileId != null && activeProfileType != null;
  bool get isAccessTokenExpired => DateTime.now().isAfter(accessTokenExpiresAt);
  bool get isRefreshTokenExpired => DateTime.now().isAfter(refreshTokenExpiresAt);

  ProfileSummary? get activeProfile {
    for (final profile in profiles) {
      if (profile.active || profile.id == activeProfileId) return profile;
    }
    return null;
  }

  AuthSession copyWith({
    String? tokenType,
    String? accessToken,
    String? refreshToken,
    DateTime? accessTokenExpiresAt,
    DateTime? refreshTokenExpiresAt,
    String? sessionId,
    String? userId,
    String? phoneNumber,
    List<ProfileType>? roles,
    List<ProfileSummary>? profiles,
    String? activeProfileId,
    ProfileType? activeProfileType,
    List<String>? permissions,
  }) {
    return AuthSession(
      tokenType: tokenType ?? this.tokenType,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      accessTokenExpiresAt: accessTokenExpiresAt ?? this.accessTokenExpiresAt,
      refreshTokenExpiresAt: refreshTokenExpiresAt ?? this.refreshTokenExpiresAt,
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      roles: roles ?? this.roles,
      profiles: profiles ?? this.profiles,
      activeProfileId: activeProfileId ?? this.activeProfileId,
      activeProfileType: activeProfileType ?? this.activeProfileType,
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  List<Object?> get props => [
    tokenType,
    accessToken,
    refreshToken,
    accessTokenExpiresAt,
    refreshTokenExpiresAt,
    sessionId,
    userId,
    phoneNumber,
    roles,
    profiles,
    activeProfileId,
    activeProfileType,
    permissions,
  ];
}
