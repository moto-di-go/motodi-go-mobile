import 'package:equatable/equatable.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document_status.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document_type.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_requirement.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';

class KycBundle extends Equatable {
  final String profileId;
  final ProfileType profileType;
  final ValidationStatus profileValidationStatus;
  final List<KycRequirement> requirements;
  final List<KycDocument> documents;

  const KycBundle({
    required this.profileId,
    required this.profileType,
    required this.profileValidationStatus,
    required this.requirements,
    required this.documents,
  });

  int get requiredCount => requirements.where((item) => item.required).length;
  int get providedCount => requirements.where((item) => item.required && item.uploaded).length;
  bool get isComplete => requiredCount > 0 && providedCount == requiredCount;
  double get completionRatio => requiredCount == 0 ? 0 : providedCount / requiredCount;
  bool get hasRejectedDocument =>
      documents.any((item) => item.status == KycDocumentStatus.rejected);

  KycDocument? latestDocumentFor(KycDocumentType type) {
    for (final document in documents) {
      if (document.type == type) return document;
    }
    return null;
  }

  KycBundle applyUpload(KycUploadResult result) {
    return KycBundle(
      profileId: profileId,
      profileType: profileType,
      profileValidationStatus: result.profileValidationStatus,
      requirements: result.requirements,
      documents: [result.document, ...documents.where((item) => item.id != result.document.id)],
    );
  }

  @override
  List<Object?> get props => [
    profileId,
    profileType,
    profileValidationStatus,
    requirements,
    documents,
  ];
}

class KycUploadResult extends Equatable {
  final String profileId;
  final ValidationStatus profileValidationStatus;
  final KycDocument document;
  final List<KycRequirement> requirements;

  const KycUploadResult({
    required this.profileId,
    required this.profileValidationStatus,
    required this.document,
    required this.requirements,
  });

  bool get isComplete => requirements.where((item) => item.required).every((item) => item.uploaded);

  @override
  List<Object?> get props => [profileId, profileValidationStatus, document, requirements];
}
