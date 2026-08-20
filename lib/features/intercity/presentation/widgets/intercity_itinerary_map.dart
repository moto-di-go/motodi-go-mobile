import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as ml;
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/cubit/intercity_booking_cubit.dart';
import 'package:motodi_go_mobile/features/urban/presentation/urban_map_style.dart';
import 'package:motodi_go_mobile/features/urban/presentation/wkt_parser.dart';

class IntercityItineraryMap extends StatefulWidget {
  final IntercityItinerary itinerary;

  const IntercityItineraryMap({super.key, required this.itinerary});

  @override
  State<IntercityItineraryMap> createState() => _IntercityItineraryMapState();
}

class _IntercityItineraryMapState extends State<IntercityItineraryMap> {
  static const _cameroon = LatLng(5.69, 12.39);

  ml.MapLibreMapController? _controller;
  bool _styleReady = false;
  String _overlayKey = '';

  @override
  void didUpdateWidget(covariant IntercityItineraryMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncOverlays();
    _syncCamera();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: ColoredBox(
        color: const Color(0xFFE7EEE6),
        child: ml.MapLibreMap(
          styleString: UrbanMapStyle.url,
          initialCameraPosition: const ml.CameraPosition(
            target: ml.LatLng(5.69, 12.39),
            zoom: 5.4,
          ),
          compassEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
          myLocationEnabled: false,
          gestureRecognizers: const {
            Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
          },
          onMapCreated: (controller) {
            _controller = controller;
          },
          onStyleLoadedCallback: () async {
            _styleReady = true;
            await _syncOverlays();
            await _syncCamera();
          },
        ),
      ),
    );
  }

  Future<void> _syncCamera() async {
    final controller = _controller;
    if (controller == null || !_styleReady) return;
    final points = _routePoints();
    if (points.length < 2) {
      await controller.animateCamera(ml.CameraUpdate.newLatLngZoom(_toMl(_cameroon), 5.4));
      return;
    }
    await controller.animateCamera(
      ml.CameraUpdate.newLatLngBounds(
        _boundsFor(points),
        left: 36,
        top: 36,
        right: 36,
        bottom: 36,
      ),
    );
  }

  Future<void> _syncOverlays() async {
    final controller = _controller;
    if (controller == null || !_styleReady) return;
    final key = '${widget.itinerary.polylineWkt}|${widget.itinerary.origin}|${widget.itinerary.destination}';
    if (key == _overlayKey) return;
    _overlayKey = key;
    await controller.clearLines();
    await controller.clearCircles();
    final route = parseWktLine(widget.itinerary.polylineWkt);
    if (route.length >= 2) {
      await controller.addLine(
        ml.LineOptions(
          geometry: route.map(_toMl).toList(),
          lineColor: _hex(AppColors.primary),
          lineWidth: 4.5,
          lineOpacity: 0.95,
        ),
      );
    }
    await _addCircle(widget.itinerary.origin, AppColors.primary, 8);
    await _addCircle(widget.itinerary.destination, AppColors.error, 8);
  }

  Future<void> _addCircle(LatLng point, Color color, double radius) async {
    if (_controller == null) return;
    await _controller!.addCircle(
      ml.CircleOptions(
        geometry: _toMl(point),
        circleRadius: radius,
        circleColor: _hex(color),
        circleStrokeColor: '#FFFFFF',
        circleStrokeWidth: 2.2,
      ),
    );
  }

  List<LatLng> _routePoints() {
    return [
      ...parseWktLine(widget.itinerary.polylineWkt),
      widget.itinerary.origin,
      widget.itinerary.destination,
    ];
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
    if ((maxLat - minLat).abs() < 0.08) {
      minLat -= 0.12;
      maxLat += 0.12;
    }
    if ((maxLon - minLon).abs() < 0.08) {
      minLon -= 0.12;
      maxLon += 0.12;
    }
    return ml.LatLngBounds(
      southwest: ml.LatLng(minLat, minLon),
      northeast: ml.LatLng(maxLat, maxLon),
    );
  }

  ml.LatLng _toMl(LatLng point) => ml.LatLng(point.latitude, point.longitude);

  String _hex(Color color) {
    final value = color.toARGB32() & 0xFFFFFF;
    return '#${value.toRadixString(16).padLeft(6, '0')}';
  }
}
