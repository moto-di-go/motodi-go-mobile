import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_bundle.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document_type.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_file_draft.dart';
import 'package:motodi_go_mobile/features/kyc/domain/repositories/kyc_repository.dart';

part 'kyc_state.dart';

@injectable
class KycCubit extends Cubit<KycState> {
  final KycRepository _repository;
  CancelToken? _cancelToken;

  KycCubit(this._repository) : super(const KycState());

  Future<void> load() async {
    emit(state.copyWith(status: KycStatus.loading, errorMessage: null, errorCode: null));
    final result = await _repository.loadCurrentDocuments();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: KycStatus.failure,
          errorMessage: failure.message,
          errorCode: failure.code,
        ),
      ),
      (bundle) => emit(state.copyWith(status: KycStatus.ready, bundle: bundle)),
    );
  }

  KycFileValidation validateDraft(KycFileDraft draft) {
    final validation = KycFileValidation.validate(draft);
    emit(
      state.copyWith(
        status: validation.isValid ? KycStatus.preview : KycStatus.invalidFile,
        draft: draft,
        fileValidation: validation,
        selectedType: draft.documentType,
        errorMessage: null,
        errorCode: null,
      ),
    );
    return validation;
  }

  Future<void> uploadDraft(KycFileDraft draft) async {
    final validation = KycFileValidation.validate(draft);
    if (!validation.isValid) {
      emit(
        state.copyWith(
          status: KycStatus.invalidFile,
          draft: draft,
          fileValidation: validation,
          uploadProgress: 0,
        ),
      );
      return;
    }

    _cancelToken = CancelToken();
    emit(
      state.copyWith(
        status: KycStatus.uploading,
        draft: draft,
        fileValidation: validation,
        uploadProgress: 0,
        errorMessage: null,
        errorCode: null,
      ),
    );

    final result = await _repository.uploadDocument(
      draft,
      cancelToken: _cancelToken,
      onProgress: (sent, total) {
        if (total <= 0 || isClosed) return;
        emit(state.copyWith(uploadProgress: sent / total));
      },
    );

    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: failure.code == 'KYC_DOCUMENT_INVALID' || failure.code == 'KYC_DOCUMENT_DUPLICATE'
              ? KycStatus.invalidFile
              : KycStatus.failure,
          errorMessage: failure.message,
          errorCode: failure.code,
          uploadProgress: 0,
        ),
      ),
      (upload) {
        final nextBundle = state.bundle?.applyUpload(upload);
        emit(
          state.copyWith(
            status: upload.isComplete ? KycStatus.submitted : KycStatus.uploadSuccess,
            uploadResult: upload,
            bundle: nextBundle,
            uploadProgress: 1,
          ),
        );
      },
    );
  }

  void cancelUpload() {
    _cancelToken?.cancel('UPLOAD_CANCELLED');
    emit(state.copyWith(status: KycStatus.ready, uploadProgress: 0));
  }

  void selectRejectedDocument(KycDocument document) {
    emit(
      state.copyWith(
        status: KycStatus.rejectedDetail,
        selectedDocument: document,
        selectedType: document.type,
      ),
    );
  }

  void selectType(KycDocumentType type) {
    emit(state.copyWith(selectedType: type));
  }

  @override
  Future<void> close() {
    _cancelToken?.cancel();
    return super.close();
  }
}
