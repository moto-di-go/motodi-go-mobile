part of 'kyc_cubit.dart';

enum KycStatus {
  initial,
  loading,
  ready,
  preview,
  invalidFile,
  uploading,
  uploadSuccess,
  submitted,
  rejectedDetail,
  verified,
  failure,
}

class KycState extends Equatable {
  final KycStatus status;
  final KycBundle? bundle;
  final KycFileDraft? draft;
  final KycFileValidation? fileValidation;
  final KycUploadResult? uploadResult;
  final KycDocument? selectedDocument;
  final KycDocumentType? selectedType;
  final double uploadProgress;
  final String? errorMessage;
  final String? errorCode;

  const KycState({
    this.status = KycStatus.initial,
    this.bundle,
    this.draft,
    this.fileValidation,
    this.uploadResult,
    this.selectedDocument,
    this.selectedType,
    this.uploadProgress = 0,
    this.errorMessage,
    this.errorCode,
  });

  bool get isLoading =>
      status == KycStatus.loading || status == KycStatus.uploading;
  bool get hasBundle => bundle != null;

  KycState copyWith({
    KycStatus? status,
    KycBundle? bundle,
    KycFileDraft? draft,
    KycFileValidation? fileValidation,
    KycUploadResult? uploadResult,
    KycDocument? selectedDocument,
    KycDocumentType? selectedType,
    double? uploadProgress,
    String? errorMessage,
    String? errorCode,
  }) {
    return KycState(
      status: status ?? this.status,
      bundle: bundle ?? this.bundle,
      draft: draft ?? this.draft,
      fileValidation: fileValidation ?? this.fileValidation,
      uploadResult: uploadResult ?? this.uploadResult,
      selectedDocument: selectedDocument ?? this.selectedDocument,
      selectedType: selectedType ?? this.selectedType,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      errorMessage: errorMessage,
      errorCode: errorCode,
    );
  }

  @override
  List<Object?> get props => [
    status,
    bundle,
    draft,
    fileValidation,
    uploadResult,
    selectedDocument,
    selectedType,
    uploadProgress,
    errorMessage,
    errorCode,
  ];
}
