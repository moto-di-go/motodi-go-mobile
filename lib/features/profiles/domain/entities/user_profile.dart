import 'package:equatable/equatable.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';

class PassengerProfileDetails extends Equatable {
  final String? preferredLanguage;
  final String? emergencyContact;

  const PassengerProfileDetails({this.preferredLanguage, this.emergencyContact});

  @override
  List<Object?> get props => [preferredLanguage, emergencyContact];
}

class DriverProfileDetails extends Equatable {
  final String? availability;
  final bool gpsConsent;
  final DateTime? lastAvailabilityChangeAt;

  const DriverProfileDetails({
    this.availability,
    this.gpsConsent = false,
    this.lastAvailabilityChangeAt,
  });

  @override
  List<Object?> get props => [availability, gpsConsent, lastAvailabilityChangeAt];
}

class MotoTaxiProfileDetails extends Equatable {
  final String? licenseNumber;
  final String? operatingZone;

  const MotoTaxiProfileDetails({this.licenseNumber, this.operatingZone});

  @override
  List<Object?> get props => [licenseNumber, operatingZone];
}

class TransporterProfileDetails extends Equatable {
  final String? permitNumber;
  final String? companyName;
  final String? vehicleId;

  const TransporterProfileDetails({this.permitNumber, this.companyName, this.vehicleId});

  @override
  List<Object?> get props => [permitNumber, companyName, vehicleId];
}

class AgencyProfileDetails extends Equatable {
  final String? legalName;
  final String? tradeRegisterNumber;
  final String? billingPlan;

  const AgencyProfileDetails({this.legalName, this.tradeRegisterNumber, this.billingPlan});

  @override
  List<Object?> get props => [legalName, tradeRegisterNumber, billingPlan];
}

class UserProfile extends Equatable {
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

  const UserProfile({
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

  bool get canBeShownInMobile => type.isSelfService;
  bool get isValidated => validationStatus == ValidationStatus.validated;
  bool get requiresValidation =>
      type == ProfileType.passenger ||
      type == ProfileType.mototaxi ||
      type == ProfileType.transporter;

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    validationStatus,
    displayName,
    avatarUrl,
    averageRating,
    active,
    createdAt,
    updatedAt,
    passenger,
    driver,
    motoTaxi,
    transporter,
    agency,
    allowedActions,
  ];
}
