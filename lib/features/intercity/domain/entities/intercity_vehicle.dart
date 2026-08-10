// Role : Vehicule appartenant a un profil transporteur/mototaxi, utilise a la publication.
class IntercityVehicle {
  final String id;
  final String ownerProfileId;
  final String type;
  final int? capacity;
  final String validationStatus;
  final bool active;
  final String photoUrl;

  const IntercityVehicle({
    required this.id,
    required this.ownerProfileId,
    required this.type,
    this.capacity,
    required this.validationStatus,
    required this.active,
    required this.photoUrl,
  });

  bool get isUsable => active && validationStatus.toUpperCase() == 'VALIDATED';
}
