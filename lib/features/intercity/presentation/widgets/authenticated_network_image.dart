import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:motodi_go_mobile/core/storage/auth_storage_keys.dart';

// Role : Affiche une image protegee (photo vehicule) en ajoutant le Bearer token
// via Dio, car les endpoints binaires ne passent pas par le ChopperClient/CachedNetworkImage.
class AuthenticatedNetworkImage extends StatefulWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget Function(BuildContext context)? placeholderBuilder;
  final Widget Function(BuildContext context)? errorBuilder;

  const AuthenticatedNetworkImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderBuilder,
    this.errorBuilder,
  });

  @override
  State<AuthenticatedNetworkImage> createState() => _AuthenticatedNetworkImageState();
}

class _AuthenticatedNetworkImageState extends State<AuthenticatedNetworkImage> {
  static final Map<String, Uint8List> _cache = {};
  static const _storage = FlutterSecureStorage();
  static final Dio _dio = Dio();

  late Future<Uint8List> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant AuthenticatedNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _future = _load();
    }
  }

  Future<Uint8List> _load() async {
    final cached = _cache[widget.path];
    if (cached != null) return cached;

    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080/api/v1';
    final normalizedBase = baseUrl.replaceFirst(RegExp(r'/$'), '');
    var relative = widget.path;
    if (relative.startsWith(normalizedBase)) {
      relative = relative.substring(normalizedBase.length);
    }
    if (relative.startsWith('/api/v1/')) {
      relative = relative.substring('/api/v1'.length);
    }
    final normalizedPath = relative.startsWith('/') ? relative : '/$relative';
    final url = widget.path.startsWith('http') && !widget.path.startsWith(normalizedBase)
        ? widget.path
        : '$normalizedBase$normalizedPath';

    final token = await _storage.read(key: AuthStorageKeys.accessToken);
    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          validateStatus: (status) => status != null && status >= 200 && status < 300,
          headers: {if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token'},
        ),
      );
      final bytes = Uint8List.fromList(response.data ?? const []);
      if (bytes.isEmpty) {
        throw StateError('Photo véhicule vide ($url)');
      }
      _cache[widget.path] = bytes;
      return bytes;
    } on DioException catch (error) {
      throw StateError(
        'Photo véhicule indisponible (${error.response?.statusCode ?? 'réseau'}): $url',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = FutureBuilder<Uint8List>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return widget.placeholderBuilder?.call(context) ?? _defaultPlaceholder();
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return widget.errorBuilder?.call(context) ?? _defaultError();
        }
        return Image.memory(
          snapshot.data!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          errorBuilder: (context, error, stackTrace) =>
              widget.errorBuilder?.call(context) ?? _defaultError(),
        );
      },
    );

    final sized = SizedBox(width: widget.width, height: widget.height, child: content);
    if (widget.borderRadius == null) return sized;
    return ClipRRect(borderRadius: widget.borderRadius!, child: sized);
  }

  Widget _defaultPlaceholder() {
    return Container(
      color: const Color(0xFFF1F2ED),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _defaultError() {
    return Container(
      color: const Color(0xFFF1F2ED),
      alignment: Alignment.center,
      child: const Icon(Icons.directions_car_filled_rounded, color: Color(0xFF9AA49D), size: 32),
    );
  }
}
