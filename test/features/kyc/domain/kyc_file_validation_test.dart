import 'package:flutter_test/flutter_test.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document_type.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_file_draft.dart';

void main() {
  test('accepts JPG, PNG and PDF files below 5 Mo', () {
    for (final draft in [
      _draft(fileName: 'cni.jpg', mimeType: 'image/jpeg'),
      _draft(fileName: 'photo.png', mimeType: 'image/png'),
      _draft(fileName: 'carte-grise.pdf', mimeType: 'application/pdf'),
    ]) {
      expect(KycFileValidation.validate(draft).isValid, isTrue);
    }
  });

  test('rejects unsupported, empty and too large files', () {
    final unsupported = KycFileValidation.validate(
      _draft(fileName: 'document.txt', mimeType: 'text/plain'),
    );
    final empty = KycFileValidation.validate(_draft(sizeBytes: 0));
    final tooLarge = KycFileValidation.validate(
      _draft(sizeBytes: KycFileValidation.maxSizeBytes + 1),
    );

    expect(unsupported.issues, contains(KycFileIssue.unsupportedFormat));
    expect(empty.issues, contains(KycFileIssue.empty));
    expect(tooLarge.issues, contains(KycFileIssue.tooLarge));
  });
}

KycFileDraft _draft({
  String fileName = 'document.jpg',
  String mimeType = 'image/jpeg',
  int sizeBytes = 1024,
}) {
  return KycFileDraft(
    documentType: KycDocumentType.cni,
    path: '/tmp/$fileName',
    fileName: fileName,
    mimeType: mimeType,
    sizeBytes: sizeBytes,
  );
}
