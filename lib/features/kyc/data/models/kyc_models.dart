import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_bundle.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document_status.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document_type.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_requirement.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';

class KycRequirementModel {
  final KycDocumentType type;
  final bool required;
  final bool uploaded;
  final KycDocumentStatus latestStatus;

  const KycRequirementModel({
    required this.type,
    required this.required,
    required this.uploaded,
    required this.latestStatus,
  });

  factory KycRequirementModel.fromJson(Map<String, dynamic> json) {
    return KycRequirementModel(
      type: KycDocumentType.fromApi(json['type'] as String?),
      required: json['required'] as bool? ?? true,
      uploaded: json['uploaded'] as bool? ?? false,
      latestStatus: KycDocumentStatus.fromApi(json['latestStatus'] as String?),
    );
  }

  KycRequirement toEntity() {
    return KycRequirement(
      type: type,
      required: required,
      uploaded: uploaded,
      latestStatus: latestStatus,
    );
  }
}

class KycDocumentModel {
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

  const KycDocumentModel({
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

  factory KycDocumentModel.fromJson(Map<String, dynamic> json) {
    return KycDocumentModel(
      id: json['id'] as String? ?? '',
      profileId: json['profileId'] as String? ?? '',
      vehicleId: json['vehicleId'] as String?,
      type: KycDocumentType.fromApi(json['type'] as String?),
      status: KycDocumentStatus.fromApi(json['status'] as String?),
      fileName: json['fileName'] as String?,
      mimeType: json['mimeType'] as String? ?? 'application/octet-stream',
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      rejectionReason: json['rejectionReason'] as String?,
      uploadedAt: DateTime.tryParse(json['uploadedAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }

  KycDocument toEntity() {
    return KycDocument(
      id: id,
      profileId: profileId,
      vehicleId: vehicleId,
      type: type,
      status: status,
      fileName: fileName,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      rejectionReason: rejectionReason,
      uploadedAt: uploadedAt,
      updatedAt: updatedAt,
    );
  }
}

class KycDocumentsResponseModel {
  final String profileId;
  final ProfileType profileType;
  final ValidationStatus profileValidationStatus;
  final List<KycRequirementModel> requirements;
  final List<KycDocumentModel> documents;

  const KycDocumentsResponseModel({
    required this.profileId,
    required this.profileType,
    required this.profileValidationStatus,
    required this.requirements,
    required this.documents,
  });

  factory KycDocumentsResponseModel.fromJson(Map<String, dynamic> json) {
    return KycDocumentsResponseModel(
      profileId: json['profileId'] as String? ?? '',
      profileType: ProfileType.fromApi(json['profileType'] as String?),
      profileValidationStatus: ValidationStatus.fromApi(json['profileValidationStatus'] as String?),
      requirements: (json['requirements'] as List<dynamic>? ?? [])
          .map((value) => KycRequirementModel.fromJson(Map<String, dynamic>.from(value as Map)))
          .toList(),
      documents: (json['documents'] as List<dynamic>? ?? [])
          .map((value) => KycDocumentModel.fromJson(Map<String, dynamic>.from(value as Map)))
          .toList(),
    );
  }

  KycBundle toEntity() {
    return KycBundle(
      profileId: profileId,
      profileType: profileType,
      profileValidationStatus: profileValidationStatus,
      requirements: requirements.map((item) => item.toEntity()).toList(),
      documents: documents.map((item) => item.toEntity()).toList(),
    );
  }
}

class UploadKycDocumentResponseModel {
  final String profileId;
  final ValidationStatus profileValidationStatus;
  final KycDocumentModel document;
  final List<KycRequirementModel> requirements;

  const UploadKycDocumentResponseModel({
    required this.profileId,
    required this.profileValidationStatus,
    required this.document,
    required this.requirements,
  });

  factory UploadKycDocumentResponseModel.fromJson(Map<String, dynamic> json) {
    return UploadKycDocumentResponseModel(
      profileId: json['profileId'] as String? ?? '',
      profileValidationStatus: ValidationStatus.fromApi(json['profileValidationStatus'] as String?),
      document: KycDocumentModel.fromJson(Map<String, dynamic>.from(json['document'] as Map)),
      requirements: (json['requirements'] as List<dynamic>? ?? [])
          .map((value) => KycRequirementModel.fromJson(Map<String, dynamic>.from(value as Map)))
          .toList(),
    );
  }

  KycUploadResult toEntity() {
    return KycUploadResult(
      profileId: profileId,
      profileValidationStatus: profileValidationStatus,
      document: document.toEntity(),
      requirements: requirements.map((item) => item.toEntity()).toList(),
    );
  }
}
