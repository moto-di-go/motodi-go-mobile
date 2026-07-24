import 'package:equatable/equatable.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document_status.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document_type.dart';

class KycDocument extends Equatable {
  final String id;
  final String profileId;
  final String? vehicleId;
  final KycDocumentType type;
  final KycDocumentStatus status;
  final String? fileName;
  final String mimeType;
  final int sizeBytes;
  final String? rejectionReason;
  final DateTime? uploadedAt;
  final DateTime? updatedAt;

  const KycDocument({
    required this.id,
    required this.profileId,
    this.vehicleId,
    required this.type,
    required this.status,
    this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    this.rejectionReason,
    this.uploadedAt,
    this.updatedAt,
  });

  String get displayName =>
      fileName?.trim().isNotEmpty == true ? fileName!.trim() : type.shortLabel;
  double get sizeMb => sizeBytes / (1024 * 1024);

  @override
  List<Object?> get props => [
    id,
    profileId,
    vehicleId,
    type,
    status,
    fileName,
    mimeType,
    sizeBytes,
    rejectionReason,
    uploadedAt,
    updatedAt,
  ];
}
