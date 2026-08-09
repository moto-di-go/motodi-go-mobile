enum KycDocumentType {
  cni,
  driverLicense,
  vehicleRegistration,
  insurance,
  profilePhoto,
  vehiclePhoto,
  unknown;

  static KycDocumentType fromApi(String? value) {
    return switch (value?.toUpperCase()) {
      'CNI' => KycDocumentType.cni,
      'DRIVER_LICENSE' => KycDocumentType.driverLicense,
      'VEHICLE_REGISTRATION' => KycDocumentType.vehicleRegistration,
      'INSURANCE' => KycDocumentType.insurance,
      'PROFILE_PHOTO' => KycDocumentType.profilePhoto,
      'VEHICLE_PHOTO' => KycDocumentType.vehiclePhoto,
      _ => KycDocumentType.unknown,
    };
  }

  String get apiValue {
    return switch (this) {
      KycDocumentType.cni => 'CNI',
      KycDocumentType.driverLicense => 'DRIVER_LICENSE',
      KycDocumentType.vehicleRegistration => 'VEHICLE_REGISTRATION',
      KycDocumentType.insurance => 'INSURANCE',
      KycDocumentType.profilePhoto => 'PROFILE_PHOTO',
      KycDocumentType.vehiclePhoto => 'VEHICLE_PHOTO',
      KycDocumentType.unknown => 'UNKNOWN',
    };
  }

  String get label {
    return switch (this) {
      KycDocumentType.cni => "Carte nationale d'identite",
      KycDocumentType.driverLicense => 'Permis de conduire',
      KycDocumentType.vehicleRegistration => 'Carte grise',
      KycDocumentType.insurance => 'Assurance',
      KycDocumentType.profilePhoto => 'Photo de profil',
      KycDocumentType.vehiclePhoto => 'Photo du véhicule',
      KycDocumentType.unknown => 'Document',
    };
  }

  String get shortLabel {
    return switch (this) {
      KycDocumentType.cni => "Carte d'identite",
      KycDocumentType.driverLicense => 'Permis de conduire',
      KycDocumentType.vehicleRegistration => 'Carte grise',
      KycDocumentType.insurance => 'Assurance',
      KycDocumentType.profilePhoto => 'Photo de profil',
      KycDocumentType.vehiclePhoto => 'Photo du véhicule',
      KycDocumentType.unknown => 'Document',
    };
  }

  String get sectionLabel {
    return switch (this) {
      KycDocumentType.cni || KycDocumentType.profilePhoto => 'IDENTITE',
      KycDocumentType.driverLicense => 'AUTORISATION DE CONDUITE',
      KycDocumentType.vehicleRegistration ||
      KycDocumentType.insurance ||
      KycDocumentType.vehiclePhoto => 'VEHICULE',
      KycDocumentType.unknown => 'DOCUMENTS',
    };
  }
}
