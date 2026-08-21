import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as ml;
import 'package:motodi_go_mobile/features/trips/domain/entities/trip.dart';
import 'package:motodi_go_mobile/features/urban/presentation/urban_map_style.dart';

class TripTrackMap extends StatefulWidget {
  final Trip trip;
  final LatLng? passengerPosition;

  const TripTrackMap({super.key, required this.trip, this.passengerPosition});

  @override
  State<TripTrackMap> createState() => _TripTrackMapState();
}

class _TripTrackMapState extends State<TripTrackMap> {
  static const _fallback = LatLng(3.848, 11.502);

  ml.MapLibreMapController? _controller;
  bool _styleReady = false;
  String _overlayKey = '';

  @override
  void didUpdateWidget(covariant TripTrackMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncOverlays();
    _syncCamera();
  }

  @override
  Widget build(BuildContext context) {
    final initial = _center();
    return ColoredBox(
      color: const Color(0xFFE7EEE6),
      child: ml.MapLibreMap(
        styleString: UrbanMapStyle.url,
        initialCameraPosition: ml.CameraPosition(target: _toMl(initial), zoom: 13.2),
        compassEnabled: false,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
        myLocationEnabled: false,
        gestureRecognizers: const {
          Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
        },
        onMapCreated: (controller) => _controller = controller,
        onStyleLoadedCallback: () async {
          _styleReady = true;
          await _syncOverlays();
          await _syncCamera(force: true);
        },
      ),
    );
  }

  LatLng _center() {
    final driver = widget.trip.driverPosition;
    if (driver != null) return LatLng(driver.lat, driver.lon);
    final passenger = widget.passengerPosition;
    if (passenger != null) return passenger;
    if (widget.trip.originLat != null && widget.trip.originLon != null) {
      return LatLng(widget.trip.originLat!, widget.trip.originLon!);
    }
    return _fallback;
  }

  Future<void> _syncCamera({bool force = false}) async {
    final controller = _controller;
    if (controller == null || !_styleReady) return;
    final points = _points();
    if (points.length >= 2) {
      await controller.animateCamera(
        ml.CameraUpdate.newLatLngBounds(
          _boundsFor(points),
          left: 56,
          top: 96,
          right: 56,
          bottom: 280,
        ),
      );
      return;
    }
    if (points.isNotEmpty || force) {
      await controller.animateCamera(ml.CameraUpdate.newLatLngZoom(_toMl(_center()), 13.2));
    }
  }

  Future<void> _syncOverlays() async {
    final controller = _controller;
    if (controller == null || !_styleReady) return;
    final key =
        '${widget.trip.driverPosition}|${widget.passengerPosition}|${widget.trip.originLat}|${widget.trip.destinationLat}';
    if (key == _overlayKey) return;
    _overlayKey = key;
    await controller.clearCircles();

    final origin = widget.trip.originLat != null && widget.trip.originLon != null
        ? LatLng(widget.trip.originLat!, widget.trip.originLon!)
        : null;
    final dest = widget.trip.destinationLat != null && widget.trip.destinationLon != null
        ? LatLng(widget.trip.destinationLat!, widget.trip.destinationLon!)
        : null;
    final passenger = widget.passengerPosition ?? origin;
    final driver = widget.trip.driverPosition;

    if (origin != null) await _addCircle(origin, const Color(0xFF16A34A), 7);
    if (dest != null) await _addCircle(dest, const Color(0xFFDC2626), 7);
    if (passenger != null) await _addCircle(passenger, const Color(0xFF2563EB), 9);
    if (driver != null) {
      await _addCircle(LatLng(driver.lat, driver.lon), const Color(0xFFEAB308), 10);
    }
  }

  Future<void> _addCircle(LatLng point, Color color, double radius) async {
    await _controller?.addCircle(
      ml.CircleOptions(
        geometry: _toMl(point),
        circleRadius: radius,
        circleColor: _hex(color),
        circleStrokeWidth: 2,
        circleStrokeColor: '#FFFFFF',
      ),
    );
  }

  List<LatLng> _points() {
    final points = <LatLng>[];
    if (widget.trip.originLat != null && widget.trip.originLon != null) {
      points.add(LatLng(widget.trip.originLat!, widget.trip.originLon!));
    }
    if (widget.trip.destinationLat != null && widget.trip.destinationLon != null) {
      points.add(LatLng(widget.trip.destinationLat!, widget.trip.destinationLon!));
    }
    final passenger = widget.passengerPosition;
    if (passenger != null) points.add(passenger);
    final driver = widget.trip.driverPosition;
    if (driver != null) points.add(LatLng(driver.lat, driver.lon));
    return points;
  }

  ml.LatLngBounds _boundsFor(List<LatLng> points) {
    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLon = points.first.longitude;
    var maxLon = points.first.longitude;
    for (final p in points.skip(1)) {
      minLat = minLat < p.latitude ? minLat : p.latitude;
      maxLat = maxLat > p.latitude ? maxLat : p.latitude;
      minLon = minLon < p.longitude ? minLon : p.longitude;
      maxLon = maxLon > p.longitude ? maxLon : p.longitude;
    }
    return ml.LatLngBounds(
      southwest: ml.LatLng(minLat, minLon),
      northeast: ml.LatLng(maxLat, maxLon),
    );
  }

  ml.LatLng _toMl(LatLng p) => ml.LatLng(p.latitude, p.longitude);

  String _hex(Color color) {
    final value = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${value.substring(2)}';
  }
}
