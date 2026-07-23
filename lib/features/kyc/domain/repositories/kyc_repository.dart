import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_bundle.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_file_draft.dart';

abstract class KycRepository {
  Future<Either<Failure, KycBundle>> loadCurrentDocuments();

  Future<Either<Failure, KycUploadResult>> uploadDocument(
    KycFileDraft draft, {
    void Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  });
}
