import 'package:chopper/chopper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/core/config/app_config.dart';
import 'package:motodi_go_mobile/core/storage/auth_storage_keys.dart';
import 'package:motodi_go_mobile/features/auth/data/models/api_error_model.dart';
import 'package:motodi_go_mobile/features/kyc/data/models/kyc_models.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_file_draft.dart';

abstract class KycRemoteDataSource {
  Future<KycDocumentsResponseModel> loadCurrentDocuments();

  Future<UploadKycDocumentResponseModel> uploadDocument(
    KycFileDraft draft, {
    void Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  });
}

@LazySingleton(as: KycRemoteDataSource)
class KycRemoteDataSourceImpl implements KycRemoteDataSource {
  final ChopperClient _client;
  final FlutterSecureStorage _secureStorage;

  KycRemoteDataSourceImpl(this._client, this._secureStorage);

  @override
  Future<KycDocumentsResponseModel> loadCurrentDocuments() async {
    final response = await _client.get<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse('/kyc/documents'),
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return KycDocumentsResponseModel.fromJson(response.body ?? <String, dynamic>{});
  }

  @override
  Future<UploadKycDocumentResponseModel> uploadDocument(
    KycFileDraft draft, {
    void Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final token = await _secureStorage.read(key: AuthStorageKeys.accessToken);
    if (token == null || token.isEmpty) {
      throw const ApiException('SESSION_EXPIRED', 'Session expiree.', statusCode: 401);
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl(),
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    final formData = FormData.fromMap({
      'type': draft.documentType.apiValue,
      'file': await MultipartFile.fromFile(
        draft.path,
        filename: draft.fileName,
        contentType: MediaType.parse(draft.mimeType),
      ),
    });

    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/kyc/documents',
        data: formData,
        cancelToken: cancelToken,
        onSendProgress: onProgress,
      );
      return UploadKycDocumentResponseModel.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (error) {
      throw _apiException(error);
    }
  }

  String _baseUrl() {
    return AppConfig.apiBaseUrl.replaceFirst(
      RegExp(r'/$'),
      '',
    );
  }

  ApiException _apiException(DioException error) {
    final response = error.response;
    final data = response?.data;
    if (data is Map<String, dynamic>) {
      final apiError = ApiErrorModel.fromJson(data);
      return ApiException(apiError.errorCode, apiError.message, statusCode: response?.statusCode);
    }
    if (data is Map) {
      final apiError = ApiErrorModel.fromJson(Map<String, dynamic>.from(data));
      return ApiException(apiError.errorCode, apiError.message, statusCode: response?.statusCode);
    }
    if (CancelToken.isCancel(error)) {
      return const ApiException('UPLOAD_CANCELLED', 'Envoi annule.');
    }
    return ApiException(
      response?.statusCode == 401 ? 'SESSION_EXPIRED' : 'KYC_UPLOAD_FAILED',
      error.message ?? 'Envoi du document impossible.',
      statusCode: response?.statusCode,
    );
  }
}
