import 'package:equatable/equatable.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';

class ProfileInput extends Equatable {
  final ProfileType type;
  final String displayName;
  final String? preferredLanguage;
  final String? emergencyContact;
  final String? licenseNumber;
  final String? operatingZone;
  final String? companyName;
  final String? permitNumber;

  const ProfileInput({
    required this.type,
    required this.displayName,
    this.preferredLanguage,
    this.emergencyContact,
    this.licenseNumber,
    this.operatingZone,
    this.companyName,
    this.permitNumber,
  });

  @override
  List<Object?> get props => [
    type,
    displayName,
    preferredLanguage,
    emergencyContact,
    licenseNumber,
    operatingZone,
    companyName,
    permitNumber,
  ];
}
