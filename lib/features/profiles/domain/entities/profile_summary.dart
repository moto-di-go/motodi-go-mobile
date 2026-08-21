import 'package:equatable/equatable.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';

class ProfileSummary extends Equatable {
  final String id;
  final ProfileType type;
  final ValidationStatus validationStatus;
  final bool active;

  const ProfileSummary({
    required this.id,
    required this.type,
    required this.validationStatus,
    required this.active,
  });

  bool get isValidated => validationStatus == ValidationStatus.validated;

  @override
  List<Object?> get props => [id, type, validationStatus, active];
}
