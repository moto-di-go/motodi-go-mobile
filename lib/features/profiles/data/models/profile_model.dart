import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_summary.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_input.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/user_profile.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';

class ProfileSummaryModel {
  final String id;
  final ProfileType type;
  final ValidationStatus validationStatus;
  final bool active;

  const ProfileSummaryModel({
    required this.id,
    required this.type,
    required this.validationStatus,
    required this.active,
  });

  factory ProfileSummaryModel.fromJson(Map<String, dynamic> json) {
    return ProfileSummaryModel(
      id: json['id'] as String,
      type: ProfileType.fromApi(json['type'] as String?),
      validationStatus: ValidationStatus.fromApi(json['validationStatus'] as String?),
      active: json['active'] as bool? ?? false,
    );
  }

  factory ProfileSummaryModel.fromEntity(ProfileSummary entity) {
    return ProfileSummaryModel(
      id: entity.id,
      type: entity.type,
      validationStatus: entity.validationStatus,
      active: entity.active,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.apiValue,
      'validationStatus': validationStatus.apiValue,
      'active': active,
    };
  }

  ProfileSummary toEntity() {
    return ProfileSummary(id: id, type: type, validationStatus: validationStatus, active: active);
  }
}

class ProfileModel {
  final String id;
  final String userId;
  final ProfileType type;
  final ValidationStatus validationStatus;
  final String displayName;
  final String? avatarUrl;
  final double averageRating;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final PassengerProfileDetails? passenger;
  final DriverProfileDetails? driver;
  final MotoTaxiProfileDetails? motoTaxi;
  final TransporterProfileDetails? transporter;
  final AgencyProfileDetails? agency;
  final List<String> allowedActions;

  const ProfileModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.validationStatus,
    required this.displayName,
    this.avatarUrl,
    required this.averageRating,
    required this.active,
    this.createdAt,
    this.updatedAt,
    this.passenger,
    this.driver,
    this.motoTaxi,
    this.transporter,
    this.agency,
    required this.allowedActions,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: ProfileType.fromApi(json['type'] as String?),
      validationStatus: ValidationStatus.fromApi(json['validationStatus'] as String?),
      displayName: json['displayName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      active: json['active'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      passenger: _passenger(json['passenger']),
      driver: _driver(json['driver']),
      motoTaxi: _motoTaxi(json['motoTaxi']),
      transporter: _transporter(json['transporter']),
      agency: _agency(json['agency']),
      allowedActions: (json['allowedActions'] as List<dynamic>? ?? []).cast<String>(),
    );
  }

  static PassengerProfileDetails? _passenger(Object? source) {
    if (source == null) return null;
    final json = Map<String, dynamic>.from(source as Map);
    return PassengerProfileDetails(
      preferredLanguage: json['preferredLanguage'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
    );
  }

  static DriverProfileDetails? _driver(Object? source) {
    if (source == null) return null;
    final json = Map<String, dynamic>.from(source as Map);
    return DriverProfileDetails(
      availability: json['availability'] as String?,
      gpsConsent: json['gpsConsent'] as bool? ?? false,
      lastAvailabilityChangeAt: DateTime.tryParse(
        json['lastAvailabilityChangeAt'] as String? ?? '',
      ),
    );
  }

  static MotoTaxiProfileDetails? _motoTaxi(Object? source) {
    if (source == null) return null;
    final json = Map<String, dynamic>.from(source as Map);
    return MotoTaxiProfileDetails(
      licenseNumber: json['licenseNumber'] as String?,
      operatingZone: json['operatingZone'] as String?,
    );
  }

  static TransporterProfileDetails? _transporter(Object? source) {
    if (source == null) return null;
    final json = Map<String, dynamic>.from(source as Map);
    return TransporterProfileDetails(
      permitNumber: json['permitNumber'] as String?,
      companyName: json['companyName'] as String?,
      vehicleId: json['vehicleId'] as String?,
    );
  }

  static AgencyProfileDetails? _agency(Object? source) {
    if (source == null) return null;
    final json = Map<String, dynamic>.from(source as Map);
    return AgencyProfileDetails(
      legalName: json['legalName'] as String?,
      tradeRegisterNumber: json['tradeRegisterNumber'] as String?,
      billingPlan: json['billingPlan'] as String?,
    );
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      userId: userId,
      type: type,
      validationStatus: validationStatus,
      displayName: displayName,
      avatarUrl: avatarUrl,
      averageRating: averageRating,
      active: active,
      createdAt: createdAt,
      updatedAt: updatedAt,
      passenger: passenger,
      driver: driver,
      motoTaxi: motoTaxi,
      transporter: transporter,
      agency: agency,
      allowedActions: allowedActions,
    );
  }
}

class ProfilePayload {
  final ProfileType type;
  final String displayName;
  final String? preferredLanguage;
  final String? emergencyContact;
  final String? licenseNumber;
  final String? operatingZone;
  final String? companyName;
  final String? permitNumber;

  const ProfilePayload({
    required this.type,
    required this.displayName,
    this.preferredLanguage,
    this.emergencyContact,
    this.licenseNumber,
    this.operatingZone,
    this.companyName,
    this.permitNumber,
  });

  factory ProfilePayload.fromInput(ProfileInput input) {
    return ProfilePayload(
      type: input.type,
      displayName: input.displayName,
      preferredLanguage: input.preferredLanguage,
      emergencyContact: input.emergencyContact,
      licenseNumber: input.licenseNumber,
      operatingZone: input.operatingZone,
      companyName: input.companyName,
      permitNumber: input.permitNumber,
    );
  }

  Map<String, dynamic> toCreateJson() {
    final json = <String, dynamic>{'type': type.apiValue, 'displayName': displayName};
    switch (type) {
      case ProfileType.passenger:
        json['passenger'] = {
          'preferredLanguage': preferredLanguage ?? 'fr',
          if (emergencyContact != null && emergencyContact!.isNotEmpty)
            'emergencyContact': emergencyContact,
        };
      case ProfileType.mototaxi:
        json['motoTaxi'] = {
          if (licenseNumber != null && licenseNumber!.isNotEmpty) 'licenseNumber': licenseNumber,
          if (operatingZone != null && operatingZone!.isNotEmpty) 'operatingZone': operatingZone,
        };
      case ProfileType.transporter:
        json['transporter'] = {
          if (permitNumber != null && permitNumber!.isNotEmpty) 'permitNumber': permitNumber,
          if (companyName != null && companyName!.isNotEmpty) 'companyName': companyName,
        };
      case ProfileType.agency:
      case ProfileType.admin:
      case ProfileType.unknown:
        break;
    }
    return json;
  }
}
