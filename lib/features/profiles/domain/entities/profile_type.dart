enum ProfileType {
  passenger,
  mototaxi,
  transporter,
  agency,
  admin,
  unknown;

  static ProfileType fromApi(String? value) {
    return switch (value?.toUpperCase()) {
      'PASSENGER' => ProfileType.passenger,
      'MOTOTAXI' => ProfileType.mototaxi,
      'TRANSPORTER' => ProfileType.transporter,
      'AGENCY' => ProfileType.agency,
      'ADMIN' => ProfileType.admin,
      _ => ProfileType.unknown,
    };
  }

  String get apiValue {
    return switch (this) {
      ProfileType.passenger => 'PASSENGER',
      ProfileType.mototaxi => 'MOTOTAXI',
      ProfileType.transporter => 'TRANSPORTER',
      ProfileType.agency => 'AGENCY',
      ProfileType.admin => 'ADMIN',
      ProfileType.unknown => 'UNKNOWN',
    };
  }

  bool get isSelfService {
    return this == ProfileType.passenger ||
        this == ProfileType.mototaxi ||
        this == ProfileType.transporter;
  }
}
