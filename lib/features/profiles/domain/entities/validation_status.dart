enum ValidationStatus {
  draft,
  pending,
  validated,
  rejected,
  suspended,
  unknown;

  static ValidationStatus fromApi(String? value) {
    return switch (value?.toUpperCase()) {
      'DRAFT' => ValidationStatus.draft,
      'PENDING' => ValidationStatus.pending,
      'VALIDATED' => ValidationStatus.validated,
      'REJECTED' => ValidationStatus.rejected,
      'SUSPENDED' => ValidationStatus.suspended,
      _ => ValidationStatus.unknown,
    };
  }

  String get apiValue {
    return switch (this) {
      ValidationStatus.draft => 'DRAFT',
      ValidationStatus.pending => 'PENDING',
      ValidationStatus.validated => 'VALIDATED',
      ValidationStatus.rejected => 'REJECTED',
      ValidationStatus.suspended => 'SUSPENDED',
      ValidationStatus.unknown => 'UNKNOWN',
    };
  }
}
