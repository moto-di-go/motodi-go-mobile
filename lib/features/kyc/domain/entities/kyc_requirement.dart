import 'package:equatable/equatable.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document_status.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document_type.dart';

class KycRequirement extends Equatable {
  final KycDocumentType type;
  final bool required;
  final bool uploaded;
  final KycDocumentStatus latestStatus;

  const KycRequirement({
    required this.type,
    required this.required,
    required this.uploaded,
    required this.latestStatus,
  });

  bool get isMissing => required && !uploaded;

  @override
  List<Object?> get props => [type, required, uploaded, latestStatus];
}
