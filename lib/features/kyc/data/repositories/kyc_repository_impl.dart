import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/core/network/network_info.dart';
import 'package:motodi_go_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:motodi_go_mobile/features/auth/data/models/api_error_model.dart';
import 'package:motodi_go_mobile/features/kyc/data/datasources/kyc_remote_datasource.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_bundle.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document_status.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document_type.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_file_draft.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_requirement.dart';
import 'package:motodi_go_mobile/features/kyc/domain/repositories/kyc_repository.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';

@LazySingleton(as: KycRepository)
class KycRepositoryImpl implements KycRepository {
  final KycRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  final AuthLocalDataSource _authLocalDataSource;

  KycRepositoryImpl(
    this._remoteDataSource,
    this._networkInfo,
    this._authLocalDataSource,
  );

  @override
  Future<Either<Failure, KycBundle>> loadCurrentDocuments() async {
    if (!await _networkInfo.isConnected) {
      return left(
        const NetworkFailure(
          'Pas de connexion internet.',
          code: 'NETWORK_OFFLINE',
        ),
      );
    }
    try {
      final response = await _remoteDataSource.loadCurrentDocuments();
      return right(response.toEntity());
    } catch (error) {
      final fallback = await _fallbackBundle(error);
      if (fallback != null) return right(fallback);
      return left(_failureFromException(error));
    }
  }

  @override
  Future<Either<Failure, KycUploadResult>> uploadDocument(
    KycFileDraft draft, {
    void Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final validation = KycFileValidation.validate(draft);
    if (!validation.isValid) {
      return left(
        const ValidationFailure(
          'Ce fichier ne peut pas etre envoye.',
          code: 'KYC_FILE_INVALID',
        ),
      );
    }
    if (!await _networkInfo.isConnected) {
      return left(
        const NetworkFailure(
          'Pas de connexion internet.',
          code: 'NETWORK_OFFLINE',
        ),
      );
    }
    try {
      final response = await _remoteDataSource.uploadDocument(
        draft,
        onProgress: onProgress,
        cancelToken: cancelToken,
      );
      return right(response.toEntity());
    } catch (error) {
      return left(_failureFromException(error));
    }
  }

  Failure _failureFromException(Object error) {
    if (error is ApiException) {
      return switch (error.code) {
        'SESSION_EXPIRED' => AuthFailure(error.message, code: error.code),
        'KYC_DOCUMENT_INVALID' ||
        'KYC_DOCUMENT_DUPLICATE' ||
        'KYC_FILE_INVALID' ||
        'VALIDATION_FAILED' => ValidationFailure(
          error.message,
          code: error.code,
        ),
        'UPLOAD_CANCELLED' => ValidationFailure(
          error.message,
          code: error.code,
        ),
        _ => ServerFailure(error.message, code: error.code),
      };
    }
    return ServerFailure(error.toString());
  }

  Future<KycBundle?> _fallbackBundle(Object error) async {
    if (error is! ApiException || !_canFallbackFrom(error)) return null;
    final session = (await _authLocalDataSource.readSession())?.toEntity();
    final active = session?.activeProfile;
    if (active == null ||
        (active.type != ProfileType.mototaxi &&
            active.type != ProfileType.transporter)) {
      return null;
    }
    return KycBundle(
      profileId: active.id,
      profileType: active.type,
      profileValidationStatus: active.validationStatus,
      requirements: _defaultRequirements(
        active.type,
        active.validationStatus,
      ),
      documents: const [],
    );
  }

  bool _canFallbackFrom(ApiException error) {
    if (error.statusCode == 401 || error.statusCode == 403) return false;
    return error.statusCode == 404 ||
        (error.statusCode != null && error.statusCode! >= 500) ||
        error.code == 'HTTP_404' ||
        error.code == 'HTTP_500' ||
        error.code == 'UNKNOWN';
  }

  List<KycRequirement> _defaultRequirements(
    ProfileType profileType,
    ValidationStatus status,
  ) {
    final uploaded = status == ValidationStatus.validated;
    final latestStatus = uploaded
        ? KycDocumentStatus.accepted
        : KycDocumentStatus.missing;
    final types = <KycDocumentType>[
      KycDocumentType.cni,
      KycDocumentType.profilePhoto,
      KycDocumentType.driverLicense,
      KycDocumentType.vehicleRegistration,
      KycDocumentType.insurance,
      if (profileType == ProfileType.transporter) KycDocumentType.vehiclePhoto,
    ];
    return types.map((type) {
      return KycRequirement(
        type: type,
        required: true,
        uploaded: uploaded,
        latestStatus: latestStatus,
      );
    }).toList();
  }
}
