import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/core/network/network_info.dart';
import 'package:motodi_go_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:motodi_go_mobile/features/auth/data/models/api_error_model.dart';
import 'package:motodi_go_mobile/features/auth/data/models/auth_models.dart';
import 'package:motodi_go_mobile/features/kyc/data/datasources/kyc_remote_datasource.dart';
import 'package:motodi_go_mobile/features/kyc/data/models/kyc_models.dart';
import 'package:motodi_go_mobile/features/kyc/data/repositories/kyc_repository_impl.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document_type.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_file_draft.dart';
import 'package:motodi_go_mobile/features/profiles/data/models/profile_model.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';

class MockKycRemoteDataSource extends Mock implements KycRemoteDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late MockKycRemoteDataSource remote;
  late MockNetworkInfo network;
  late MockAuthLocalDataSource local;
  late KycRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_draft());
  });

  setUp(() {
    remote = MockKycRemoteDataSource();
    network = MockNetworkInfo();
    local = MockAuthLocalDataSource();
    repository = KycRepositoryImpl(remote, network, local);
  });

  test('loadCurrentDocuments returns NetworkFailure while offline', () async {
    when(() => network.isConnected).thenAnswer((_) async => false);

    final result = await repository.loadCurrentDocuments();

    expect(result.isLeft(), isTrue);
    result.fold((failure) => expect(failure, isA<NetworkFailure>()), (_) => fail('no data'));
    verifyNever(() => remote.loadCurrentDocuments());
  });

  test('uploadDocument rejects invalid files locally', () async {
    final invalid = _draft(fileName: 'doc.txt', mimeType: 'text/plain');

    final result = await repository.uploadDocument(invalid);

    expect(result.isLeft(), isTrue);
    result.fold((failure) {
      expect(failure, isA<ValidationFailure>());
      expect(failure.code, 'KYC_FILE_INVALID');
    }, (_) => fail('no data'));
    verifyNever(() => network.isConnected);
    verifyNever(() => remote.uploadDocument(any()));
  });

  test('uploadDocument maps API invalid document error', () async {
    when(() => network.isConnected).thenAnswer((_) async => true);
    when(
      () => remote.uploadDocument(any()),
    ).thenThrow(const ApiException('KYC_DOCUMENT_INVALID', 'Document invalide'));

    final result = await repository.uploadDocument(_draft());

    expect(result.isLeft(), isTrue);
    result.fold((failure) {
      expect(failure, isA<ValidationFailure>());
      expect(failure.code, 'KYC_DOCUMENT_INVALID');
    }, (_) => fail('no data'));
  });

  test('uploadDocument maps API duplicate document error', () async {
    when(() => network.isConnected).thenAnswer((_) async => true);
    when(() => remote.uploadDocument(any())).thenThrow(
      const ApiException(
        'KYC_DOCUMENT_DUPLICATE',
        'Ce fichier a déjà été téléversé. Choisissez-en un autre.',
      ),
    );

    final result = await repository.uploadDocument(_draft());

    expect(result.isLeft(), isTrue);
    result.fold((failure) {
      expect(failure, isA<ValidationFailure>());
      expect(failure.code, 'KYC_DOCUMENT_DUPLICATE');
      expect(failure.message, 'Ce fichier a déjà été téléversé. Choisissez-en un autre.');
    }, (_) => fail('no data'));
  });

  test('uploadDocument returns parsed upload result', () async {
    when(() => network.isConnected).thenAnswer((_) async => true);
    when(() => remote.uploadDocument(any())).thenAnswer((_) async => _uploadResponse());

    final result = await repository.uploadDocument(_draft());

    expect(result.isRight(), isTrue);
    result.fold((_) => fail('no failure'), (upload) {
      expect(upload.profileValidationStatus, ValidationStatus.pending);
      expect(upload.document.fileName, 'cni.jpg');
    });
  });

  test('loadCurrentDocuments falls back to default checklist when KYC API is missing', () async {
    when(() => network.isConnected).thenAnswer((_) async => true);
    when(
      () => remote.loadCurrentDocuments(),
    ).thenThrow(const ApiException('HTTP_404', 'Not Found', statusCode: 404));
    when(() => local.readSession()).thenAnswer((_) async => _sessionModel());

    final result = await repository.loadCurrentDocuments();

    expect(result.isRight(), isTrue);
    result.fold((_) => fail('no failure'), (bundle) {
      expect(bundle.profileType, ProfileType.mototaxi);
      expect(bundle.profileValidationStatus, ValidationStatus.pending);
      expect(bundle.requirements, hasLength(5));
      expect(bundle.providedCount, 0);
    });
  });
}

KycFileDraft _draft({
  String fileName = 'cni.jpg',
  String mimeType = 'image/jpeg',
  int sizeBytes = 2048,
}) {
  return KycFileDraft(
    documentType: KycDocumentType.cni,
    path: '/tmp/$fileName',
    fileName: fileName,
    mimeType: mimeType,
    sizeBytes: sizeBytes,
  );
}

UploadKycDocumentResponseModel _uploadResponse() {
  return UploadKycDocumentResponseModel.fromJson({
    'profileId': 'profile-1',
    'profileValidationStatus': 'PENDING',
    'document': {
      'id': 'doc-1',
      'profileId': 'profile-1',
      'type': 'CNI',
      'status': 'PENDING_REVIEW',
      'fileName': 'cni.jpg',
      'mimeType': 'image/jpeg',
      'sizeBytes': 2048,
      'uploadedAt': '2026-07-22T08:00:00.000Z',
      'updatedAt': '2026-07-22T08:00:00.000Z',
    },
    'requirements': [
      {'type': 'CNI', 'required': true, 'uploaded': true, 'latestStatus': 'PENDING_REVIEW'},
    ],
  });
}

AuthSessionModel _sessionModel() {
  return AuthSessionModel(
    tokenType: 'Bearer',
    accessToken: 'access',
    refreshToken: 'refresh',
    accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
    refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 30)),
    sessionId: 'session-1',
    userId: 'user-1',
    phoneNumber: '+237699000000',
    roles: const [ProfileType.mototaxi],
    profiles: const [
      ProfileSummaryModel(
        id: 'profile-1',
        type: ProfileType.mototaxi,
        validationStatus: ValidationStatus.pending,
        active: true,
      ),
    ],
    activeProfileId: 'profile-1',
    activeProfileType: ProfileType.mototaxi,
    permissions: const [],
  );
}
