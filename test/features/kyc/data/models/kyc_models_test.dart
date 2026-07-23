import 'package:flutter_test/flutter_test.dart';
import 'package:motodi_go_mobile/features/kyc/data/models/kyc_models.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document_status.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document_type.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';

void main() {
  test('parses KYC document checklist response', () {
    final model = KycDocumentsResponseModel.fromJson({
      'profileId': 'profile-1',
      'profileType': 'MOTOTAXI',
      'profileValidationStatus': 'PENDING',
      'requirements': [
        {
          'type': 'CNI',
          'required': true,
          'uploaded': true,
          'latestStatus': 'ACCEPTED',
        },
        {
          'type': 'INSURANCE',
          'required': true,
          'uploaded': false,
          'latestStatus': 'REJECTED',
        },
      ],
      'documents': [
        {
          'id': 'doc-1',
          'profileId': 'profile-1',
          'type': 'CNI',
          'status': 'ACCEPTED',
          'fileName': 'cni.jpg',
          'mimeType': 'image/jpeg',
          'sizeBytes': 2048,
          'uploadedAt': '2026-07-22T08:00:00.000Z',
          'updatedAt': '2026-07-22T08:00:00.000Z',
        },
      ],
    });

    final entity = model.toEntity();

    expect(entity.profileType, ProfileType.mototaxi);
    expect(entity.profileValidationStatus, ValidationStatus.pending);
    expect(entity.providedCount, 1);
    expect(entity.requirements.last.latestStatus, KycDocumentStatus.rejected);
    expect(entity.documents.single.type, KycDocumentType.cni);
    expect(entity.documents.single.displayName, 'cni.jpg');
  });
}
