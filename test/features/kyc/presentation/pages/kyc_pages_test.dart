import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/core/theme/app_theme.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:motodi_go_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_bundle.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document_status.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document_type.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_file_draft.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_requirement.dart';
import 'package:motodi_go_mobile/features/kyc/domain/repositories/kyc_repository.dart';
import 'package:motodi_go_mobile/features/kyc/presentation/cubit/kyc_cubit.dart';
import 'package:motodi_go_mobile/features/kyc/presentation/pages/kyc_pages.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_summary.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';
import 'package:motodi_go_mobile/routes/app_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';

class _FakeKycRepository implements KycRepository {
  _FakeKycRepository(this.bundle);

  final KycBundle bundle;

  @override
  Future<Either<Failure, KycBundle>> loadCurrentDocuments() async {
    return right(bundle);
  }

  @override
  Future<Either<Failure, KycUploadResult>> uploadDocument(
    KycFileDraft draft, {
    void Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    onProgress?.call(1, 1);
    return right(
      KycUploadResult(
        profileId: bundle.profileId,
        profileValidationStatus: ValidationStatus.pending,
        document: _document(
          type: draft.documentType,
          status: KycDocumentStatus.pendingReview,
          fileName: draft.fileName,
          sizeBytes: draft.sizeBytes,
        ),
        requirements: bundle.requirements,
      ),
    );
  }
}

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _FakeKycRepository kycRepository;

  setUp(() async {
    await getIt.reset();
    kycRepository = _FakeKycRepository(_kycBundle());
    getIt.registerFactory<KycCubit>(() => KycCubit(kycRepository));
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildApp(Widget child) {
    return MaterialApp(theme: AppTheme.lightTheme(), home: child);
  }

  testWidgets('documents page renders sections, add action and rejection', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(const KycDocumentsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Mes documents'), findsOneWidget);
    expect(find.text('IDENTITÉ'), findsOneWidget);
    expect(find.text('AUTORISATION DE CONDUITE'), findsOneWidget);
    expect(find.text('VÉHICULE'), findsOneWidget);
    expect(find.text('Ajouter'), findsOneWidget);
    expect(find.text('Détails'), findsOneWidget);

    await tester.ensureVisible(find.text('Ajouter'));
    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();

    expect(find.text('Ajouter un document'), findsOneWidget);
    expect(find.text('Prendre une photo'), findsOneWidget);
    expect(find.text('Choisir dans la galerie'), findsOneWidget);
    expect(find.text('Importer un PDF'), findsOneWidget);
  });

  testWidgets('preview page renders selected PDF before upload', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(KycPreviewPage(draft: _draft())));

    expect(find.text('Aperçu du document'), findsOneWidget);
    expect(find.text('carte-grise.pdf'), findsOneWidget);
    expect(find.text('PDF · 2.1 Mo · PDF'), findsOneWidget);
    expect(find.text('Envoyer'), findsOneWidget);
    expect(find.text('Reprendre'), findsOneWidget);
  });

  testWidgets('invalid file page renders validation reasons', (tester) async {
    final draft = _draft(fileName: 'carte-grise.jpg', sizeBytes: 8_800_000);
    final validation = KycFileValidation.validate(draft);

    await tester.pumpWidget(
      buildApp(
        KycInvalidFilePage(args: KycInvalidFileArgs(validation: validation)),
      ),
    );

    expect(find.text('Fichier invalide'), findsOneWidget);
    expect(
      find.textContaining('Ce fichier ne peut pas etre envoye'),
      findsOneWidget,
    );
    expect(find.textContaining('Taille trop grande'), findsOneWidget);
    expect(find.text('Choisir un autre fichier'), findsOneWidget);
  });

  testWidgets('upload success, submitted, rejected and verified pages render', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildApp(KycUploadSuccessPage(result: _uploadResult())),
    );
    expect(find.text('Document envoye'), findsOneWidget);
    expect(find.textContaining('en attente de verification'), findsOneWidget);

    await tester.pumpWidget(buildApp(const KycSubmittedPage()));
    expect(find.text('Dossier soumis'), findsOneWidget);
    expect(find.text('Dossier en cours de verification'), findsOneWidget);
    expect(find.text('Verification en cours'), findsOneWidget);

    await tester.pumpWidget(
      buildApp(KycRejectedDocumentPage(document: _rejectedInsurance())),
    );
    expect(find.text('Document rejete'), findsOneWidget);
    expect(find.text('Assurance rejetee'), findsOneWidget);
    expect(find.textContaining('document est illisible'), findsOneWidget);
    expect(find.text('Remplacer le document'), findsOneWidget);

    await tester.pumpWidget(buildApp(const KycVerifiedPage()));
    expect(find.text('Profil verifie'), findsOneWidget);
    expect(find.text('Votre profil mototaxi est valide'), findsOneWidget);
    expect(find.text('Activer mon profil'), findsOneWidget);
  });

  testWidgets('notification detail opens KYC status content', (tester) async {
    await tester.pumpWidget(
      buildApp(
        KycNotificationDetailPage(
          payload: KycNotificationPayload(
            title: 'Votre profil mototaxi est valide',
            body: 'Tous vos documents ont ete acceptes.',
            status: ValidationStatus.validated,
            occurredAt: DateTime(2026, 7, 8, 9, 12),
          ),
        ),
      ),
    );

    expect(find.text('DETAIL DE LA NOTIFICATION'), findsOneWidget);
    expect(find.text('Votre profil mototaxi est valide'), findsWidgets);
    expect(find.text('Ouvrir le statut KYC'), findsOneWidget);
  });

  testWidgets(
    'status page switches between required, in progress and history',
    (tester) async {
      kycRepository = _FakeKycRepository(_completePendingBundle());
      await getIt.reset();
      getIt.registerFactory<KycCubit>(() => KycCubit(kycRepository));

      await tester.pumpWidget(buildApp(const KycStatusPage()));
      await tester.pumpAndSettle();

      expect(find.text('Statut global'), findsOneWidget);
      expect(find.text('5 / 5 documents fournis'), findsOneWidget);

      await tester.tap(find.text('En cours'));
      await tester.pumpAndSettle();

      expect(find.text('Dossier soumis'), findsOneWidget);
      expect(find.text('Verification en cours'), findsOneWidget);

      await tester.tap(find.text('Historique'));
      await tester.pumpAndSettle();

      expect(find.text('Carte nationale d\'identite'), findsOneWidget);
      expect(find.text('Validé'), findsWidgets);
    },
  );

  testWidgets('router shows home for unvalidated driver profiles', (
    tester,
  ) async {
    final authRepository = _MockAuthRepository();
    final sessionCubit = SessionCubit(authRepository)
      ..setAuthenticated(
        _session(ProfileType.mototaxi, ValidationStatus.pending),
      );
    addTearDown(sessionCubit.close);

    final router = createAppRouter(sessionCubit)..go(RouteConstants.home);
    await tester.pumpWidget(
      BlocProvider.value(
        value: sessionCubit,
        child: MaterialApp.router(
          theme: AppTheme.lightTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Profil en attente de validation'), findsOneWidget);
    expect(find.text('Voir mes documents'), findsOneWidget);
    expect(find.text('FONCTIONS CONDUCTEUR'), findsOneWidget);

    await tester.tap(find.text('Voir mes documents'));
    await tester.pumpAndSettle();

    expect(find.text('Mes documents'), findsOneWidget);
    expect(find.text('IDENTITÉ'), findsOneWidget);
  });

  testWidgets('router lets validated driver profiles reach driver features', (
    tester,
  ) async {
    final authRepository = _MockAuthRepository();
    final sessionCubit = SessionCubit(authRepository)
      ..setAuthenticated(
        _session(ProfileType.mototaxi, ValidationStatus.validated),
      );
    addTearDown(sessionCubit.close);

    final router = createAppRouter(sessionCubit)..go(RouteConstants.home);
    await tester.pumpWidget(
      BlocProvider.value(
        value: sessionCubit,
        child: MaterialApp.router(
          theme: AppTheme.lightTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('FONCTIONS CONDUCTEUR'), findsOneWidget);
    expect(find.text('Disponible maintenant'), findsWidgets);
  });
}

KycBundle _kycBundle({
  ValidationStatus validationStatus = ValidationStatus.pending,
}) {
  return KycBundle(
    profileId: 'profile-1',
    profileType: ProfileType.mototaxi,
    profileValidationStatus: validationStatus,
    requirements: const [
      KycRequirement(
        type: KycDocumentType.cni,
        required: true,
        uploaded: true,
        latestStatus: KycDocumentStatus.accepted,
      ),
      KycRequirement(
        type: KycDocumentType.profilePhoto,
        required: true,
        uploaded: true,
        latestStatus: KycDocumentStatus.accepted,
      ),
      KycRequirement(
        type: KycDocumentType.driverLicense,
        required: true,
        uploaded: true,
        latestStatus: KycDocumentStatus.pendingReview,
      ),
      KycRequirement(
        type: KycDocumentType.vehicleRegistration,
        required: true,
        uploaded: false,
        latestStatus: KycDocumentStatus.missing,
      ),
      KycRequirement(
        type: KycDocumentType.insurance,
        required: true,
        uploaded: false,
        latestStatus: KycDocumentStatus.rejected,
      ),
    ],
    documents: [
      _document(type: KycDocumentType.cni, status: KycDocumentStatus.accepted),
      _document(
        id: 'doc-photo',
        type: KycDocumentType.profilePhoto,
        status: KycDocumentStatus.accepted,
        fileName: 'photo.jpg',
      ),
      _document(
        id: 'doc-permis',
        type: KycDocumentType.driverLicense,
        status: KycDocumentStatus.pendingReview,
        fileName: 'permis.jpg',
      ),
      _rejectedInsurance(),
    ],
  );
}

KycBundle _completePendingBundle() {
  return KycBundle(
    profileId: 'profile-1',
    profileType: ProfileType.mototaxi,
    profileValidationStatus: ValidationStatus.pending,
    requirements: const [
      KycRequirement(
        type: KycDocumentType.cni,
        required: true,
        uploaded: true,
        latestStatus: KycDocumentStatus.accepted,
      ),
      KycRequirement(
        type: KycDocumentType.profilePhoto,
        required: true,
        uploaded: true,
        latestStatus: KycDocumentStatus.accepted,
      ),
      KycRequirement(
        type: KycDocumentType.driverLicense,
        required: true,
        uploaded: true,
        latestStatus: KycDocumentStatus.pendingReview,
      ),
      KycRequirement(
        type: KycDocumentType.vehicleRegistration,
        required: true,
        uploaded: true,
        latestStatus: KycDocumentStatus.pendingReview,
      ),
      KycRequirement(
        type: KycDocumentType.insurance,
        required: true,
        uploaded: true,
        latestStatus: KycDocumentStatus.pendingReview,
      ),
    ],
    documents: [
      _document(type: KycDocumentType.cni, status: KycDocumentStatus.accepted),
      _document(
        id: 'doc-photo',
        type: KycDocumentType.profilePhoto,
        status: KycDocumentStatus.accepted,
        fileName: 'photo.jpg',
      ),
      _document(
        id: 'doc-permis',
        type: KycDocumentType.driverLicense,
        status: KycDocumentStatus.pendingReview,
        fileName: 'permis.jpg',
      ),
      _document(
        id: 'doc-carte-grise',
        type: KycDocumentType.vehicleRegistration,
        status: KycDocumentStatus.pendingReview,
        fileName: 'carte-grise.jpg',
      ),
      _document(
        id: 'doc-assurance',
        type: KycDocumentType.insurance,
        status: KycDocumentStatus.pendingReview,
        fileName: 'assurance.jpg',
      ),
    ],
  );
}

KycDocument _document({
  String id = 'doc-cni',
  required KycDocumentType type,
  required KycDocumentStatus status,
  String? fileName,
  int sizeBytes = 1_800_000,
}) {
  return KycDocument(
    id: id,
    profileId: 'profile-1',
    type: type,
    status: status,
    fileName: fileName ?? '${type.apiValue.toLowerCase()}.jpg',
    mimeType: 'image/jpeg',
    sizeBytes: sizeBytes,
    uploadedAt: DateTime(2026, 6, 12),
    updatedAt: DateTime(2026, 6, 12),
  );
}

KycDocument _rejectedInsurance() {
  return const KycDocument(
    id: 'doc-assurance',
    profileId: 'profile-1',
    type: KycDocumentType.insurance,
    status: KycDocumentStatus.rejected,
    fileName: 'assurance.jpg',
    mimeType: 'image/jpeg',
    sizeBytes: 1_800_000,
    rejectionReason:
        "le document est illisible et la date de validite n'apparait pas.",
    uploadedAt: null,
    updatedAt: null,
  );
}

KycFileDraft _draft({
  String fileName = 'carte-grise.pdf',
  int sizeBytes = 2_200_000,
}) {
  return KycFileDraft(
    documentType: KycDocumentType.vehicleRegistration,
    path: '/tmp/$fileName',
    fileName: fileName,
    mimeType: fileName.endsWith('.pdf') ? 'application/pdf' : 'image/jpeg',
    sizeBytes: sizeBytes,
  );
}

KycUploadResult _uploadResult() {
  return KycUploadResult(
    profileId: 'profile-1',
    profileValidationStatus: ValidationStatus.pending,
    document: _document(
      type: KycDocumentType.vehicleRegistration,
      status: KycDocumentStatus.pendingReview,
      fileName: 'carte-grise.jpg',
      sizeBytes: 2_200_000,
    ),
    requirements: _kycBundle().requirements,
  );
}

AuthSession _session(ProfileType type, ValidationStatus validationStatus) {
  final now = DateTime(2026, 7, 22, 8);
  return AuthSession(
    tokenType: 'Bearer',
    accessToken: 'access',
    refreshToken: 'refresh',
    accessTokenExpiresAt: now.add(const Duration(hours: 1)),
    refreshTokenExpiresAt: now.add(const Duration(days: 30)),
    sessionId: 'session-1',
    userId: 'user-1',
    phoneNumber: '+237699000000',
    roles: [type],
    profiles: [
      ProfileSummary(
        id: 'profile-1',
        type: type,
        validationStatus: validationStatus,
        active: true,
      ),
    ],
    activeProfileId: 'profile-1',
    activeProfileType: type,
    permissions: const [],
  );
}
