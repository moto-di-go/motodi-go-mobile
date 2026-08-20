import 'package:equatable/equatable.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document_type.dart';

class KycFileDraft extends Equatable {
  final KycDocumentType documentType;
  final String path;
  final String fileName;
  final String mimeType;
  final int sizeBytes;

  const KycFileDraft({
    required this.documentType,
    required this.path,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
  });

  String get extension {
    final dot = fileName.lastIndexOf('.');
    return dot < 0 ? '' : fileName.substring(dot + 1).toUpperCase();
  }

  double get sizeMb => sizeBytes / (1024 * 1024);

  @override
  List<Object?> get props => [documentType, path, fileName, mimeType, sizeBytes];
}

enum KycFileIssue { tooLarge, empty, unsupportedFormat, unreadable }

class KycFileValidation extends Equatable {
  static const int maxSizeBytes = 5 * 1024 * 1024;
  static const allowedExtensions = {'jpg', 'jpeg', 'png', 'pdf'};
  static const allowedMimeTypes = {'image/jpeg', 'image/png', 'application/pdf'};

  final KycFileDraft draft;
  final List<KycFileIssue> issues;

  const KycFileValidation({required this.draft, required this.issues});

  bool get isValid => issues.isEmpty;

  static KycFileValidation validate(KycFileDraft draft) {
    final issues = <KycFileIssue>[];
    if (draft.sizeBytes <= 0) issues.add(KycFileIssue.empty);
    if (draft.sizeBytes > maxSizeBytes) issues.add(KycFileIssue.tooLarge);
    final normalizedExtension = draft.extension.toLowerCase();
    final normalizedMimeType = draft.mimeType.toLowerCase();
    if (!allowedExtensions.contains(normalizedExtension) ||
        !allowedMimeTypes.contains(normalizedMimeType)) {
      issues.add(KycFileIssue.unsupportedFormat);
    }
    if (draft.path.trim().isEmpty) issues.add(KycFileIssue.unreadable);
    return KycFileValidation(draft: draft, issues: issues);
  }

  @override
  List<Object?> get props => [draft, issues];
}
