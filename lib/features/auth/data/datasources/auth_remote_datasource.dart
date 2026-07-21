import 'package:chopper/chopper.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/auth/data/models/api_error_model.dart';
import 'package:motodi_go_mobile/features/auth/data/models/auth_models.dart';

abstract class AuthRemoteDataSource {
  Future<RegisterResponseModel> register({
    required String phoneNumber,
    required String password,
    required String fullName,
    required bool cguAccepted,
    String locale,
  });

  Future<OtpVerifyResponseModel> verifyOtp({
    required String phoneNumber,
    required String code,
    required String purpose,
  });

  Future<OtpResendResponseModel> resendOtp({required String phoneNumber, required String purpose});

  Future<AuthSessionModel> login({required String phoneNumber, required String password});
  Future<AuthSessionModel> refresh({required String refreshToken});
  Future<void> logout();
  Future<void> forgotPassword(String phoneNumber);

  Future<void> resetPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
  });
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ChopperClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<RegisterResponseModel> register({
    required String phoneNumber,
    required String password,
    required String fullName,
    required bool cguAccepted,
    String locale = 'fr-CM',
  }) async {
    final body = await _postMap('/auth/register', {
      'phoneNumber': phoneNumber,
      'password': password,
      'fullName': fullName,
      'locale': locale,
      'cguAccepted': cguAccepted,
    });
    return RegisterResponseModel.fromJson(body);
  }

  @override
  Future<OtpVerifyResponseModel> verifyOtp({
    required String phoneNumber,
    required String code,
    required String purpose,
  }) async {
    final body = await _postMap('/auth/otp/verify', {
      'phoneNumber': phoneNumber,
      'code': code,
      'purpose': purpose,
    });
    return OtpVerifyResponseModel.fromJson(body);
  }

  @override
  Future<OtpResendResponseModel> resendOtp({
    required String phoneNumber,
    required String purpose,
  }) async {
    final body = await _postMap('/auth/otp/resend', {
      'phoneNumber': phoneNumber,
      'purpose': purpose,
    });
    return OtpResendResponseModel.fromJson(body);
  }

  @override
  Future<AuthSessionModel> login({required String phoneNumber, required String password}) async {
    final body = await _postMap('/auth/login', {'phoneNumber': phoneNumber, 'password': password});
    return AuthSessionModel.fromJson(body);
  }

  @override
  Future<AuthSessionModel> refresh({required String refreshToken}) async {
    final body = await _postMap('/auth/refresh', {'refreshToken': refreshToken});
    return AuthSessionModel.fromJson(body);
  }

  @override
  Future<void> logout() async {
    await _postVoid('/auth/logout', const {});
  }

  @override
  Future<void> forgotPassword(String phoneNumber) async {
    await _postVoid('/auth/password/forgot', {'phoneNumber': phoneNumber});
  }

  @override
  Future<void> resetPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
  }) async {
    await _postVoid('/auth/password/reset', {
      'phoneNumber': phoneNumber,
      'code': code,
      'newPassword': newPassword,
    });
  }

  Future<Map<String, dynamic>> _postMap(String path, Map<String, dynamic> body) async {
    final response = await _client.post<Map<String, dynamic>, Map<String, dynamic>>(
      Uri.parse(path),
      body: body,
    );
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
    return response.body ?? <String, dynamic>{};
  }

  Future<void> _postVoid(String path, Map<String, dynamic> body) async {
    final response = await _client.post<dynamic, dynamic>(Uri.parse(path), body: body);
    if (!response.isSuccessful) throw ApiException.fromResponse(response);
  }
}
