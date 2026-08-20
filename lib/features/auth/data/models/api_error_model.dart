import 'dart:convert';

import 'package:chopper/chopper.dart';

class ApiErrorModel {
  final String errorCode;
  final String message;
  final String? correlationId;
  final DateTime? timestamp;

  const ApiErrorModel({
    required this.errorCode,
    required this.message,
    this.correlationId,
    this.timestamp,
  });

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) {
    final status = json['status'];
    final statusCode = status is int ? status : int.tryParse('$status');
    final fallbackCode = statusCode == null ? 'UNKNOWN' : 'HTTP_$statusCode';
    final fallbackMessage = json['message'] as String? ?? json['error'] as String?;
    return ApiErrorModel(
      errorCode: json['errorCode'] as String? ?? fallbackCode,
      message: fallbackMessage ?? 'Une erreur est survenue',
      correlationId: json['correlationId'] as String?,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? ''),
    );
  }

  factory ApiErrorModel.fromResponse(Response<dynamic> response) {
    final body = response.error ?? response.body;
    if (body is Map<String, dynamic>) {
      return ApiErrorModel.fromJson(body);
    }
    if (body is Map) {
      return ApiErrorModel.fromJson(Map<String, dynamic>.from(body));
    }
    if (body is String && body.trim().isNotEmpty) {
      try {
        final decoded = json.decode(body);
        if (decoded is Map<String, dynamic>) {
          return ApiErrorModel.fromJson(decoded);
        }
        if (decoded is Map) {
          return ApiErrorModel.fromJson(Map<String, dynamic>.from(decoded));
        }
      } catch (_) {
        return ApiErrorModel(errorCode: 'HTTP_${response.statusCode}', message: body);
      }
    }
    return ApiErrorModel(
      errorCode: response.statusCode == 401 ? 'SESSION_EXPIRED' : 'HTTP_${response.statusCode}',
      message: response.error?.toString() ?? 'Requête impossible.',
    );
  }
}

class ApiException implements Exception {
  final String code;
  final String message;
  final int? statusCode;

  const ApiException(this.code, this.message, {this.statusCode});

  factory ApiException.fromResponse(Response<dynamic> response) {
    final error = ApiErrorModel.fromResponse(response);
    return ApiException(error.errorCode, error.message, statusCode: response.statusCode);
  }

  @override
  String toString() => 'ApiException($code, $message, $statusCode)';
}
