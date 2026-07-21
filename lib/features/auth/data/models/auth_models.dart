import 'dart:convert';

import 'package:motodi_go_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:motodi_go_mobile/features/auth/domain/entities/register_result.dart';
import 'package:motodi_go_mobile/features/profiles/data/models/profile_model.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';

class RegisterResponseModel {
  final String userId;
  final String phoneNumber;
  final String status;
  final DateTime otpExpiresAt;

  const RegisterResponseModel({
    required this.userId,
    required this.phoneNumber,
    required this.status,
    required this.otpExpiresAt,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      userId: json['userId'] as String,
      phoneNumber: json['phoneNumber'] as String,
      status: json['status'] as String,
      otpExpiresAt: DateTime.parse(json['otpExpiresAt'] as String),
    );
  }

  RegisterResult toEntity() {
    return RegisterResult(
      userId: userId,
      phoneNumber: phoneNumber,
      status: status,
      otpExpiresAt: otpExpiresAt,
    );
  }
}

class OtpVerifyResponseModel {
  final String userId;
  final String phoneNumber;
  final String status;

  const OtpVerifyResponseModel({
    required this.userId,
    required this.phoneNumber,
    required this.status,
  });

  factory OtpVerifyResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpVerifyResponseModel(
      userId: json['userId'] as String,
      phoneNumber: json['phoneNumber'] as String,
      status: json['status'] as String,
    );
  }

  OtpResult toEntity() {
    return OtpResult(userId: userId, phoneNumber: phoneNumber, status: status);
  }
}

class OtpResendResponseModel {
  final String phoneNumber;
  final String purpose;
  final DateTime otpExpiresAt;

  const OtpResendResponseModel({
    required this.phoneNumber,
    required this.purpose,
    required this.otpExpiresAt,
  });

  factory OtpResendResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpResendResponseModel(
      phoneNumber: json['phoneNumber'] as String,
      purpose: json['purpose'] as String,
      otpExpiresAt: DateTime.parse(json['otpExpiresAt'] as String),
    );
  }

  OtpResendResult toEntity() {
    return OtpResendResult(phoneNumber: phoneNumber, purpose: purpose, otpExpiresAt: otpExpiresAt);
  }
}

class AuthSessionModel {
  final String tokenType;
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiresAt;
  final DateTime refreshTokenExpiresAt;
  final String sessionId;
  final String userId;
  final String phoneNumber;
  final List<ProfileType> roles;
  final List<ProfileSummaryModel> profiles;
  final String? activeProfileId;
  final ProfileType? activeProfileType;
  final List<String> permissions;

  const AuthSessionModel({
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

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      accessTokenExpiresAt: DateTime.parse(json['accessTokenExpiresAt'] as String),
      refreshTokenExpiresAt: DateTime.parse(json['refreshTokenExpiresAt'] as String),
      sessionId: json['sessionId'] as String,
      userId: json['userId'] as String,
      phoneNumber: json['phoneNumber'] as String,
      roles: (json['roles'] as List<dynamic>? ?? [])
          .map((value) => ProfileType.fromApi(value as String?))
          .where((role) => role != ProfileType.unknown)
          .toList(),
      profiles: (json['profiles'] as List<dynamic>? ?? [])
          .map((value) => ProfileSummaryModel.fromJson(Map<String, dynamic>.from(value as Map)))
          .toList(),
      activeProfileId: json['activeProfileId'] as String?,
      activeProfileType: json['activeProfileType'] == null
          ? null
          : ProfileType.fromApi(json['activeProfileType'] as String?),
      permissions: (json['permissions'] as List<dynamic>? ?? []).cast<String>(),
    );
  }

  factory AuthSessionModel.fromEntity(AuthSession entity) {
    return AuthSessionModel(
      tokenType: entity.tokenType,
      accessToken: entity.accessToken,
      refreshToken: entity.refreshToken,
      accessTokenExpiresAt: entity.accessTokenExpiresAt,
      refreshTokenExpiresAt: entity.refreshTokenExpiresAt,
      sessionId: entity.sessionId,
      userId: entity.userId,
      phoneNumber: entity.phoneNumber,
      roles: entity.roles,
      profiles: entity.profiles.map(ProfileSummaryModel.fromEntity).toList(),
      activeProfileId: entity.activeProfileId,
      activeProfileType: entity.activeProfileType,
      permissions: entity.permissions,
    );
  }

  factory AuthSessionModel.fromJsonString(String source) {
    return AuthSessionModel.fromJson(json.decode(source) as Map<String, dynamic>);
  }

  Map<String, dynamic> toJson() {
    return {
      'tokenType': tokenType,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'accessTokenExpiresAt': accessTokenExpiresAt.toIso8601String(),
      'refreshTokenExpiresAt': refreshTokenExpiresAt.toIso8601String(),
      'sessionId': sessionId,
      'userId': userId,
      'phoneNumber': phoneNumber,
      'roles': roles.map((role) => role.apiValue).toList(),
      'profiles': profiles.map((profile) => profile.toJson()).toList(),
      'activeProfileId': activeProfileId,
      'activeProfileType': activeProfileType?.apiValue,
      'permissions': permissions,
    };
  }

  String toJsonString() => json.encode(toJson());

  AuthSession toEntity() {
    return AuthSession(
      tokenType: tokenType,
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessTokenExpiresAt: accessTokenExpiresAt,
      refreshTokenExpiresAt: refreshTokenExpiresAt,
      sessionId: sessionId,
      userId: userId,
      phoneNumber: phoneNumber,
      roles: roles,
      profiles: profiles.map((profile) => profile.toEntity()).toList(),
      activeProfileId: activeProfileId,
      activeProfileType: activeProfileType == ProfileType.unknown ? null : activeProfileType,
      permissions: permissions,
    );
  }
}
