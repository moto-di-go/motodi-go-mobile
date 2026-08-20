import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_bundle.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document_status.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document_type.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_file_draft.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_requirement.dart';
import 'package:motodi_go_mobile/features/kyc/domain/repositories/kyc_repository.dart';
import 'package:motodi_go_mobile/features/kyc/presentation/cubit/kyc_cubit.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';

class MockKycRepository extends Mock implements KycRepository {}

void main() {
  late MockKycRepository repository;

  setUpAll(() {
    registerFallbackValue(_draft());
    registerFallbackValue(CancelToken());
  });

  setUp(() {
    repository = MockKycRepository();
  });

  blocTest<KycCubit, KycState>(
    'load emits ready bundle',
    build: () {
      when(() => repository.loadCurrentDocuments()).thenAnswer((_) async => right(_bundle()));
      return KycCubit(repository);
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const KycState(status: KycStatus.loading),
      KycState(status: KycStatus.ready, bundle: _bundle()),
    ],
  );

  blocTest<KycCubit, KycState>(
    'validateDraft emits invalid file state',
    build: () => KycCubit(repository),
    act: (cubit) => cubit.validateDraft(_draft(fileName: 'bad.txt', mimeType: 'text/plain')),
    expect: () => [
      isA<KycState>()
          .having((state) => state.status, 'status', KycStatus.invalidFile)
          .having((state) => state.fileValidation?.isValid, 'valid', isFalse),
    ],
  );

  blocTest<KycCubit, KycState>(
    'uploadDraft emits progress and upload success',
    build: () {
      when(
        () => repository.uploadDocument(
          any(),
          onProgress: any(named: 'onProgress'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((invocation) async {
        final onProgress = invocation.namedArguments[#onProgress] as void Function(int, int)?;
        onProgress?.call(1, 2);
        return right(_uploadResult(complete: false));
      });
      return KycCubit(repository);
    },
    seed: () => KycState(bundle: _bundle()),
    act: (cubit) => cubit.uploadDraft(_draft()),
    expect: () => [
      isA<KycState>()
          .having((state) => state.status, 'status', KycStatus.uploading)
          .having((state) => state.uploadProgress, 'progress', 0),
      isA<KycState>()
          .having((state) => state.status, 'status', KycStatus.uploading)
          .having((state) => state.uploadProgress, 'progress', 0.5),
      isA<KycState>()
          .having((state) => state.status, 'status', KycStatus.uploadSuccess)
          .having((state) => state.uploadProgress, 'progress', 1),
    ],
  );

  blocTest<KycCubit, KycState>(
    'load maps repository failures',
    build: () {
      when(
        () => repository.loadCurrentDocuments(),
      ).thenAnswer((_) async => left(const NetworkFailure('Offline', code: 'NETWORK_OFFLINE')));
      return KycCubit(repository);
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const KycState(status: KycStatus.loading),
      const KycState(
        status: KycStatus.failure,
        errorMessage: 'Offline',
        errorCode: 'NETWORK_OFFLINE',
      ),
    ],
  );

  blocTest<KycCubit, KycState>(
    'uploadDraft maps duplicate file to invalid file state',
    build: () {
      when(
        () => repository.uploadDocument(
          any(),
          onProgress: any(named: 'onProgress'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => left(
          const ValidationFailure(
            'Ce fichier a déjà été téléversé. Choisissez-en un autre.',
            code: 'KYC_DOCUMENT_DUPLICATE',
          ),
        ),
      );
      return KycCubit(repository);
    },
    act: (cubit) => cubit.uploadDraft(_draft()),
    expect: () => [
      isA<KycState>()
          .having((state) => state.status, 'status', KycStatus.uploading)
          .having((state) => state.uploadProgress, 'progress', 0),
      isA<KycState>()
          .having((state) => state.status, 'status', KycStatus.invalidFile)
          .having(
            (state) => state.errorMessage,
            'message',
            'Ce fichier a déjà été téléversé. Choisissez-en un autre.',
          )
          .having((state) => state.errorCode, 'code', 'KYC_DOCUMENT_DUPLICATE'),
    ],
  );
}

KycFileDraft _draft({String fileName = 'cni.jpg', String mimeType = 'image/jpeg'}) {
  return KycFileDraft(
    documentType: KycDocumentType.cni,
    path: '/tmp/$fileName',
    fileName: fileName,
    mimeType: mimeType,
    sizeBytes: 2048,
  );
}

KycBundle _bundle() {
  return const KycBundle(
    profileId: 'profile-1',
    profileType: ProfileType.mototaxi,
    profileValidationStatus: ValidationStatus.pending,
    requirements: [
      KycRequirement(
        type: KycDocumentType.cni,
        required: true,
        uploaded: false,
        latestStatus: KycDocumentStatus.missing,
      ),
    ],
    documents: [],
  );
}

KycUploadResult _uploadResult({required bool complete}) {
  return KycUploadResult(
    profileId: 'profile-1',
    profileValidationStatus: ValidationStatus.pending,
    document: _document(),
    requirements: [
      const KycRequirement(
        type: KycDocumentType.cni,
        required: true,
        uploaded: true,
        latestStatus: KycDocumentStatus.pendingReview,
      ),
      KycRequirement(
        type: KycDocumentType.insurance,
        required: true,
        uploaded: complete,
        latestStatus: complete ? KycDocumentStatus.accepted : KycDocumentStatus.missing,
      ),
    ],
  );
}

KycDocument _document() {
  return const KycDocument(
    id: 'doc-1',
    profileId: 'profile-1',
    type: KycDocumentType.cni,
    status: KycDocumentStatus.pendingReview,
    fileName: 'cni.jpg',
    mimeType: 'image/jpeg',
    sizeBytes: 2048,
  );
}
