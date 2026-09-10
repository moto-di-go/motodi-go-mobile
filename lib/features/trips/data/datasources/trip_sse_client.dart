import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/core/config/app_config.dart';
import 'package:motodi_go_mobile/core/storage/auth_storage_keys.dart';

/// Lightweight SSE client for `/realtime/sse?channel=trip:{id}` with JWT.
/// Falls back silently when the stream cannot be established.
@lazySingleton
class TripSseClient {
  TripSseClient(this._storage);

  final FlutterSecureStorage _storage;

  Future<StreamSubscription<List<int>>?> subscribe({
    required String tripId,
    required void Function(Map<String, dynamic> event) onEvent,
    void Function(Object error)? onError,
    void Function()? onDone,
  }) async {
    try {
      final token = await _storage.read(key: AuthStorageKeys.accessToken);
      if (token == null || token.isEmpty) return null;

      final baseUrl = AppConfig.apiBaseUrl;
      final uri = Uri.parse(
        '$baseUrl/realtime/sse',
      ).replace(queryParameters: {'channel': 'trip:$tripId'});

      final client = http.Client();
      final request = http.Request('GET', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'text/event-stream';
      request.headers['Cache-Control'] = 'no-cache';

      final response = await client.send(request).timeout(const Duration(seconds: 12));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        client.close();
        return null;
      }

      final buffer = StringBuffer();
      return response.stream.listen(
        (chunk) {
          buffer.write(utf8.decode(chunk, allowMalformed: true));
          final raw = buffer.toString();
          if (!raw.contains('\n\n')) return;
          final parts = raw.split('\n\n');
          buffer
            ..clear()
            ..write(parts.last);
          for (var i = 0; i < parts.length - 1; i++) {
            final payload = _parseSseBlock(parts[i]);
            if (payload != null) onEvent(payload);
          }
        },
        onError: (Object error, StackTrace stack) {
          client.close();
          onError?.call(error);
          if (kDebugMode) debugPrint('Trip SSE error: $error');
        },
        onDone: () {
          client.close();
          onDone?.call();
        },
        cancelOnError: true,
      );
    } catch (error) {
      if (kDebugMode) debugPrint('Trip SSE unavailable: $error');
      onError?.call(error);
      return null;
    }
  }

  Map<String, dynamic>? _parseSseBlock(String block) {
    final dataLines = <String>[];
    for (final line in block.split('\n')) {
      final trimmed = line.trimRight();
      if (trimmed.startsWith('data:')) {
        dataLines.add(trimmed.substring(5).trimLeft());
      }
    }
    if (dataLines.isEmpty) return null;
    final joined = dataLines.join('\n');
    try {
      final decoded = json.decode(joined);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return {'raw': joined};
    }
    return null;
  }
}
