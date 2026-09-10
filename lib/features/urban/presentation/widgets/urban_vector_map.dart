import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as ml;
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_models.dart';
import 'package:motodi_go_mobile/features/urban/presentation/urban_map_style.dart';
import 'package:motodi_go_mobile/features/urban/presentation/urban_ride_cubit.dart';
import 'package:motodi_go_mobile/features/urban/presentation/urban_ride_state.dart';
import 'package:motodi_go_mobile/features/urban/presentation/wkt_parser.dart';

class UrbanVectorMap extends StatefulWidget {
  final UrbanRideState state;
  final UrbanRideCubit cubit;

  const UrbanVectorMap({super.key, required this.state, required this.cubit});

  @override
  State<UrbanVectorMap> createState() => _UrbanVectorMapState();
}

class _UrbanVectorMapState extends State<UrbanVectorMap> {
  ml.MapLibreMapController? _controller;
  bool _styleReady = false;
  String _overlayKey = '';
  LatLng? _lastCenter;
  String _lastFitKey = '';

  UrbanRideState get state => widget.state;

  @override
  void didUpdateWidget(covariant UrbanVectorMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncCamera();
    _syncOverlays();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFE7EEE6),
      child: ml.MapLibreMap(
        styleString: UrbanMapStyle.url,
        initialCameraPosition: ml.CameraPosition(target: _toMl(state.center), zoom: 14),
        compassEnabled: false,
        rotateGesturesEnabled: true,
        tiltGesturesEnabled: false,
        trackCameraPosition: true,
        myLocationEnabled: false,
        onMapCreated: (controller) {
          _controller = controller;
          _lastCenter = state.center;
        },
        onStyleLoadedCallback: () async {
          _styleReady = true;
          await _syncOverlays();
          await _syncCamera(force: true);
        },
        onMapClick: (point, latLng) {
          widget.cubit.onMapTap(LatLng(latLng.latitude, latLng.longitude));
        },
      ),
    );
  }

  Future<void> _syncCamera({bool force = false}) async {
    final controller = _controller;
    if (controller == null || !_styleReady) return;
    final fitKey = '${state.selectedPolyline}|${state.origin}|${state.destination}';
    final routePoints = _routePoints();
    if (routePoints.length >= 2 && (force || fitKey != _lastFitKey)) {
      _lastFitKey = fitKey;
      await controller.animateCamera(
        ml.CameraUpdate.newLatLngBounds(
          _boundsFor(routePoints),
          left: 72,
          top: 72,
          right: 72,
          bottom: 72,
        ),
      );
      return;
    }
    if (force || _lastCenter != state.center) {
      _lastCenter = state.center;
      await controller.animateCamera(ml.CameraUpdate.newLatLngZoom(_toMl(state.center), 14));
    }
  }

  Future<void> _syncOverlays() async {
    final controller = _controller;
    if (controller == null || !_styleReady) return;
    final key = _currentOverlayKey();
    if (key == _overlayKey) return;
    _overlayKey = key;
    await controller.clearLines();
    await controller.clearCircles();
    for (final layer in state.visibleLayers) {
      final points = parseWktLine(layer.geometryWkt);
      if (points.length < 2) continue;
      await controller.addLine(
        ml.LineOptions(
          geometry: points.map(_toMl).toList(),
          lineColor: _hex(_layerColor(layer)),
          lineWidth: 5,
          lineOpacity: 0.85,
        ),
      );
    }
    final selected = parseWktLine(state.selectedPolyline);
    if (selected.length >= 2) {
      await controller.addLine(
        ml.LineOptions(
          geometry: selected.map(_toMl).toList(),
          lineColor: _hex(AppColors.primary),
          lineWidth: 4.5,
          lineOpacity: 0.95,
        ),
      );
    }
    if (state.step == UrbanRideStep.compareRoutes) {
      for (final option in state.routeOptions.where(
        (item) => item.kind == RouteOptionKind.fastest,
      )) {
        final points = parseWktLine(option.polyline);
        if (points.length < 2) continue;
        await controller.addLine(
          ml.LineOptions(
            geometry: points.map(_toMl).toList(),
            lineColor: _hex(AppColors.info),
            lineWidth: 4.5,
            lineOpacity: 0.8,
          ),
        );
      }
    }
    await _addCircle(state.userPosition, AppColors.info, 10);
    await _addCircle(state.origin, AppColors.primary, 7);
    await _addCircle(state.destination, AppColors.error, 9);
    for (final driver in state.drivers) {
      final selectedDriver = driver.id == state.selectedDriverId;
      await _addCircle(
        LatLng(driver.lat, driver.lon),
        selectedDriver ? AppColors.primaryDark : AppColors.primary,
        selectedDriver ? 8 : 6,
      );
    }
  }

  Future<void> _addCircle(LatLng? point, Color color, double radius) async {
    if (point == null || _controller == null) return;
    await _controller!.addCircle(
      ml.CircleOptions(
        geometry: _toMl(point),
        circleRadius: radius,
        circleColor: _hex(color),
        circleStrokeColor: '#FFFFFF',
        circleStrokeWidth: 2.4,
      ),
    );
  }

  List<LatLng> _routePoints() {
    final points = <LatLng>[
      ...parseWktLine(state.selectedPolyline),
      if (state.origin != null) state.origin!,
      if (state.destination != null) state.destination!,
    ];
    return points;
  }

  String _currentOverlayKey() {
    return [
      state.selectedPolyline,
      state.step.name,
      state.origin,
      state.destination,
      state.userPosition,
      state.selectedDriverId,
      state.drivers.map((driver) => '${driver.id}:${driver.lat}:${driver.lon}').join('|'),
      state.visibleLayers.map((layer) => '${layer.id}:${layer.geometryWkt}').join('|'),
    ].join('::');
  }

  ml.LatLngBounds _boundsFor(List<LatLng> points) {
    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLon = points.first.longitude;
    var maxLon = points.first.longitude;
    for (final point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLon = minLon < point.longitude ? minLon : point.longitude;
      maxLon = maxLon > point.longitude ? maxLon : point.longitude;
    }
    return ml.LatLngBounds(
      southwest: ml.LatLng(minLat, minLon),
      northeast: ml.LatLng(maxLat, maxLon),
    );
  }

  Color _layerColor(TrafficLayer layer) {
    if (layer.isStale()) return const Color(0xFF9CA3AF);
    return switch (layer.type.toUpperCase()) {
      'CONGESTION' => const Color(0xFFF59E0B),
      'ROADWORK' => const Color(0xFFF59E0B),
      'DAMAGED_ROAD' => const Color(0xFFEF4444),
      'ALTERNATIVE_ROUTE' => const Color(0xFF3B82F6),
      _ => switch (layer.severity.toUpperCase()) {
        'CRITICAL' || 'HIGH' => const Color(0xFFEF4444),
        'MEDIUM' => const Color(0xFFF59E0B),
        _ => const Color(0xFFFBBF24),
      },
    };
  }

  ml.LatLng _toMl(LatLng point) => ml.LatLng(point.latitude, point.longitude);

  String _hex(Color color) {
    final value = color.toARGB32() & 0xFFFFFF;
    return '#${value.toRadixString(16).padLeft(6, '0')}';
  }
}
