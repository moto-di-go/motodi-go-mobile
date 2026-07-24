enum KycDocumentStatus {
  uploaded,
  encrypted,
  pendingReview,
  accepted,
  rejected,
  expired,
  missing,
  unknown;

  static KycDocumentStatus fromApi(String? value) {
    return switch (value?.toUpperCase()) {
      'UPLOADED' => KycDocumentStatus.uploaded,
      'ENCRYPTED' => KycDocumentStatus.encrypted,
      'PENDING_REVIEW' => KycDocumentStatus.pendingReview,
      'ACCEPTED' => KycDocumentStatus.accepted,
      'REJECTED' => KycDocumentStatus.rejected,
      'EXPIRED' => KycDocumentStatus.expired,
      null => KycDocumentStatus.missing,
      _ => KycDocumentStatus.unknown,
    };
  }

  String get apiValue {
    return switch (this) {
      KycDocumentStatus.uploaded => 'UPLOADED',
      KycDocumentStatus.encrypted => 'ENCRYPTED',
      KycDocumentStatus.pendingReview => 'PENDING_REVIEW',
      KycDocumentStatus.accepted => 'ACCEPTED',
      KycDocumentStatus.rejected => 'REJECTED',
      KycDocumentStatus.expired => 'EXPIRED',
      KycDocumentStatus.missing => 'MISSING',
      KycDocumentStatus.unknown => 'UNKNOWN',
    };
  }

  bool get countsAsProvided {
    return this == KycDocumentStatus.uploaded ||
        this == KycDocumentStatus.encrypted ||
        this == KycDocumentStatus.pendingReview ||
        this == KycDocumentStatus.accepted;
  }

  bool get isRejected => this == KycDocumentStatus.rejected;
  bool get isAccepted => this == KycDocumentStatus.accepted;
  bool get isPending => this == KycDocumentStatus.pendingReview;
}
