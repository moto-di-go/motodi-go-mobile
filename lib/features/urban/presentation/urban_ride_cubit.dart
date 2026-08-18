import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_destination_history_store.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_estimate_parser.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_filters.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_geo.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_location_source.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_mock_data.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_models.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_remote_datasource.dart';
import 'package:motodi_go_mobile/features/urban/presentation/urban_ride_state.dart';
import 'package:motodi_go_mobile/features/urban/presentation/wkt_parser.dart';

class UrbanRideCubit extends Cubit<UrbanRideState> {
  UrbanRideCubit({
    required UrbanRemoteDataSource remote,
    required UrbanDestinationHistoryStore history,
    required UrbanLocationSource location,
    this.pollInterval = const Duration(seconds: 8),
    this.searchMinDuration = const Duration(milliseconds: 900),
  })  : _remote = remote,
        _history = history,
        _location = location,
        super(const UrbanRideState());

  final UrbanRemoteDataSource _remote;
  final UrbanDestinationHistoryStore _history;
  final UrbanLocationSource _location;
  final Duration pollInterval;
  final Duration searchMinDuration;
  Timer? _poll;
  Timer? _geocodeDebounce;
  StreamSubscription<UrbanLocationResult>? _locationSub;

  Future<void> bootstrap() async {
    emit(state.copyWith(
      locating: true,
      locationError: null,
      apiError: null,
      history: _history.load(),
    ));
    await Future.wait([
      _locate(),
      _loadWallet(),
      _loadPlaces(),
      refreshLayers(),
    ]);
  }

  Future<void> _locate() async {
    emit(state.copyWith(locating: true));
    final result = await _location.currentPosition();
    if (result.position != null) {
      emit(state.copyWith(
        locating: false,
        userPosition: result.position,
        origin: result.position,
        center: result.position,
        locationError: null,
      ));
      _watchLocation();
      await _reverseOrigin(result.position!);
    } else {
      emit(state.copyWith(
        locating: false,
        origin: state.origin ?? kYaoundeCenter,
        locationError: result.error,
      ));
    }
  }

  void _watchLocation() {
    _locationSub?.cancel();
    _locationSub = _location.watchPosition().listen((result) {
      if (isClosed || result.position == null) return;
      emit(state.copyWith(
        userPosition: result.position,
        origin: state.origin ?? result.position,
        locationError: null,
      ));
    });
  }

  Future<void> _reverseOrigin(LatLng point) async {
    try {
      final place = await _remote.reverseGeocode(lat: point.latitude, lon: point.longitude);
      if (place != null && !isClosed) {
        emit(state.copyWith(originLabel: place.label));
      }
    } catch (_) {
      // Reverse geocode is optional.
    }
  }

  Future<void> _loadWallet() async {
    try {
      final wallet = await _remote.wallet();
      if (!isClosed) {
        emit(state.copyWith(walletBalance: wallet?.currentBalance));
      }
    } catch (_) {
      if (!isClosed) emit(state.copyWith(walletBalance: null));
    }
  }

  Future<void> _loadPlaces() async {
    try {
      final places = await _remote.popularPlaces();
      if (isClosed) return;
      if (places != null && places.isNotEmpty) {
        emit(state.copyWith(popularPlaces: places, popularPlacesDemo: false));
      } else {
        emit(state.copyWith(popularPlaces: kYaoundePopularPlaces, popularPlacesDemo: true));
      }
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(popularPlaces: kYaoundePopularPlaces, popularPlacesDemo: true));
      }
    }
  }

  Future<void> refreshLayers() async {
    try {
      final layers = await _remote.layers();
      if (!isClosed) {
        emit(state.copyWith(layers: layers, layersFetchedAt: DateTime.now(), apiError: null));
      }
    } catch (error) {
      if (!isClosed) emit(state.copyWith(apiError: error.toString()));
    }
  }

  void openDestination() {
    emit(state.copyWith(step: UrbanRideStep.destination, returnTo: UrbanRideStep.home));
  }

  void closeTo(UrbanRideStep step) {
    if (!_keepsPolling(step)) _stopPoll();
    emit(state.copyWith(step: step));
  }

  void back() {
    switch (state.step) {
      case UrbanRideStep.destination:
      case UrbanRideStep.pickDestination:
        emit(state.copyWith(step: UrbanRideStep.home));
      case UrbanRideStep.calculating:
      case UrbanRideStep.tripSummary:
        emit(state.copyWith(step: UrbanRideStep.destination));
      case UrbanRideStep.priceDetail:
      case UrbanRideStep.routeOptions:
      case UrbanRideStep.compareRoutes:
        emit(state.copyWith(step: UrbanRideStep.tripSummary));
      case UrbanRideStep.searching:
      case UrbanRideStep.results:
      case UrbanRideStep.empty:
        _stopPoll();
        emit(state.copyWith(step: UrbanRideStep.tripSummary));
      case UrbanRideStep.filters:
        emit(state.copyWith(step: UrbanRideStep.results));
      case UrbanRideStep.driverDetail:
        emit(state.copyWith(step: UrbanRideStep.results));
      case UrbanRideStep.confirm:
        emit(state.copyWith(step: UrbanRideStep.driverDetail));
      case UrbanRideStep.layers:
      case UrbanRideStep.incident:
        emit(state.copyWith(step: state.returnTo, selectedIncident: null));
      case UrbanRideStep.confirmed:
        resetToHome();
      case UrbanRideStep.home:
        break;
    }
  }

  void startPickDestination() {
    emit(state.copyWith(step: UrbanRideStep.pickDestination, returnTo: UrbanRideStep.destination));
  }

  void setOriginOnMap(LatLng point) {
    emit(state.copyWith(origin: point, center: point, originLabel: 'Point choisi'));
  }

  void onMapTap(LatLng point) {
    if (state.step == UrbanRideStep.pickDestination) {
      emit(state.copyWith(
        destination: point,
        destinationLabel: 'Point sur la carte',
        destinationQuery: 'Point sur la carte',
        center: point,
      ));
      return;
    }
    final hit = nearestLayer(point);
    if (hit != null) {
      openIncident(hit);
    }
  }

  TrafficLayer? nearestLayer(LatLng point, {double maxKm = 0.12}) {
    TrafficLayer? best;
    var bestKm = maxKm;
    for (final layer in state.visibleLayers) {
      final points = parseWktLine(layer.geometryWkt);
      if (points.isEmpty) {
        final poly = parseWktPolygon(layer.geometryWkt);
        for (final candidate in poly) {
          final km = haversineKm(point, candidate);
          if (km < bestKm) {
            bestKm = km;
            best = layer;
          }
        }
        continue;
      }
      for (final candidate in points) {
        final km = haversineKm(point, candidate);
        if (km < bestKm) {
          bestKm = km;
          best = layer;
        }
      }
    }
    return best;
  }

  Future<void> confirmPickedDestination() async {
    final destination = state.destination;
    if (destination == null) return;
    await selectDestination(
      label: state.destinationLabel.isEmpty ? 'Point sur la carte' : state.destinationLabel,
      point: destination,
    );
  }

  void updateDestinationQuery(String value) {
    emit(state.copyWith(destinationQuery: value, geocodeFailed: false, geocoding: value.trim().isNotEmpty));
    _scheduleGeocode(value);
  }

  void clearDestinationQuery() {
    _geocodeDebounce?.cancel();
    emit(state.copyWith(
      destinationQuery: '',
      destinationLabel: '',
      destination: null,
      geocodeResults: const [],
      geocodeFailed: false,
      geocoding: false,
    ));
  }

  void _scheduleGeocode(String value) {
    _geocodeDebounce?.cancel();
    final query = value.trim();
    if (query.isEmpty) {
      emit(state.copyWith(geocodeResults: const [], geocodeFailed: false, geocoding: false));
      return;
    }
    emit(state.copyWith(geocoding: true));
    _geocodeDebounce = Timer(const Duration(milliseconds: 280), () => _geocode(query));
  }

  Future<void> _geocode(String query) async {
    try {
      final origin = state.origin ?? state.userPosition;
      final places = await _remote.geocode(
        query,
        lat: origin?.latitude,
        lon: origin?.longitude,
      );
      if (isClosed || state.destinationQuery.trim() != query) return;
      emit(state.copyWith(
        geocodeResults: places ?? const [],
        geocodeFailed: places == null,
        geocoding: false,
      ));
    } catch (_) {
      if (!isClosed && state.destinationQuery.trim() == query) {
        emit(state.copyWith(geocodeResults: const [], geocodeFailed: true, geocoding: false));
      }
    }
  }

  Future<void> selectHistory(DestinationHistoryEntry entry) {
    return selectDestination(label: entry.label, point: entry.point);
  }

  Future<void> selectPopularPlace(UrbanPlace place) {
    return selectDestination(label: place.label, point: place.point);
  }

  Future<void> selectDestination({required String label, required LatLng point}) async {
    final origin = state.origin ?? state.userPosition ?? kYaoundeCenter;
    emit(state.copyWith(
      destination: point,
      destinationLabel: label,
      destinationQuery: label,
      step: UrbanRideStep.calculating,
      apiError: null,
    ));
    final history = await _history.add(
      DestinationHistoryEntry(label: label, lat: point.latitude, lon: point.longitude, savedAt: DateTime.now()),
    );
    if (!isClosed) emit(state.copyWith(history: history));
    await _estimateRoute(origin, point);
  }

  Future<void> _estimateRoute(LatLng origin, LatLng destination) async {
    FareEstimate? estimate;
    try {
      estimate = await _remote.estimate(
        originLat: origin.latitude,
        originLon: origin.longitude,
        destinationLat: destination.latitude,
        destinationLon: destination.longitude,
      );
    } catch (error) {
      if (!isClosed) emit(state.copyWith(apiError: error.toString()));
    }
    if (isClosed) return;
    final options = resolveRouteOptions(
      estimate: estimate,
      origin: origin,
      destination: destination,
    );
    final demo = estimate == null || estimate.options.isEmpty;
    emit(state.copyWith(
      estimate: estimate,
      routeOptions: options,
      selectedKind: RouteOptionKind.recommended,
      routeOptionsDemo: demo,
      step: UrbanRideStep.tripSummary,
    ));
  }

  void openPriceDetail() {
    emit(state.copyWith(step: UrbanRideStep.priceDetail, returnTo: UrbanRideStep.tripSummary));
  }

  void openRouteOptions({UrbanRideStep from = UrbanRideStep.tripSummary}) {
    emit(state.copyWith(step: UrbanRideStep.routeOptions, returnTo: from));
  }

  void openCompareRoutes({UrbanRideStep from = UrbanRideStep.tripSummary}) {
    emit(state.copyWith(step: UrbanRideStep.compareRoutes, returnTo: from));
  }

  void selectRouteOption(RouteOptionKind kind) {
    emit(state.copyWith(selectedKind: kind, step: UrbanRideStep.tripSummary));
  }

  FareBreakdown breakdownForSelection() {
    return resolveFareBreakdown(state.estimate, selectedAmount: state.selectedAmount);
  }

  Future<void> searchMototaxis() async {
    final origin = state.origin ?? state.userPosition;
    if (origin == null) {
      emit(state.copyWith(apiError: 'Choisissez une origine sur la carte.'));
      return;
    }
    emit(state.copyWith(step: UrbanRideStep.searching, searching: true, apiError: null));
    final started = DateTime.now();
    try {
      final nearby = await _remote.nearby(
        lat: origin.latitude,
        lon: origin.longitude,
        radiusKm: state.filters.radiusKm,
        destLat: state.destination?.latitude,
        destLon: state.destination?.longitude,
      );
      final elapsed = DateTime.now().difference(started);
      if (elapsed < searchMinDuration) {
        await Future<void>.delayed(searchMinDuration - elapsed);
      }
      if (isClosed) return;
      _applyNearby(nearby);
    } catch (error) {
      final elapsed = DateTime.now().difference(started);
      if (elapsed < searchMinDuration) {
        await Future<void>.delayed(searchMinDuration - elapsed);
      }
      if (isClosed) return;
      emit(state.copyWith(
        searching: false,
        step: UrbanRideStep.empty,
        apiError: error.toString(),
        drivers: const [],
      ));
    }
  }

  void _applyNearby(NearbySearchResult nearby, {bool silent = false}) {
    final enriched = enrichNearbyDrivers(nearby.items, fallbackPrice: state.selectedAmount);
    final filtered = applyUrbanFilters(enriched, state.filters);
    final nextStep = silent
        ? state.step
        : (filtered.isEmpty ? UrbanRideStep.empty : UrbanRideStep.results);
    emit(state.copyWith(
      nearby: nearby,
      drivers: filtered,
      searching: false,
      step: nextStep,
      apiError: null,
    ));
    if (_keepsPolling(nextStep)) {
      _startPoll();
    } else {
      _stopPoll();
    }
  }

  Future<void> refreshNearby({bool silent = true}) async {
    final origin = state.origin ?? state.userPosition;
    if (origin == null) return;
    try {
      final nearby = await _remote.nearby(
        lat: origin.latitude,
        lon: origin.longitude,
        radiusKm: state.filters.radiusKm,
        destLat: state.destination?.latitude,
        destLon: state.destination?.longitude,
      );
      if (!isClosed) _applyNearby(nearby, silent: silent);
    } catch (error) {
      if (!silent && !isClosed) emit(state.copyWith(apiError: error.toString()));
    }
  }

  void openFilters() {
    emit(state.copyWith(
      step: UrbanRideStep.filters,
      returnTo: UrbanRideStep.results,
      draftFilters: state.filters,
    ));
  }

  void updateDraftFilters(UrbanFilters filters) {
    emit(state.copyWith(draftFilters: filters));
  }

  Future<void> applyFilters() async {
    final previous = state.filters;
    final next = state.draftFilters;
    emit(state.copyWith(filters: next, step: UrbanRideStep.searching, searching: true));
    if (previous.radiusKm != next.radiusKm) {
      await searchMototaxis();
      return;
    }
    final enriched = enrichNearbyDrivers(state.nearby?.items ?? const [], fallbackPrice: state.selectedAmount);
    final filtered = applyUrbanFilters(enriched, next);
    emit(state.copyWith(
      drivers: filtered,
      searching: false,
      step: filtered.isEmpty ? UrbanRideStep.empty : UrbanRideStep.results,
    ));
    if (filtered.isNotEmpty) _startPoll();
  }

  Future<void> widenRadius() async {
    final widened = (state.filters.radiusKm + 2).clamp(2, 10).toDouble();
    emit(state.copyWith(
      filters: state.filters.copyWith(radiusKm: widened),
      draftFilters: state.draftFilters.copyWith(radiusKm: widened),
    ));
    await searchMototaxis();
  }

  void selectDriver(String id) {
    emit(state.copyWith(selectedDriverId: id, step: UrbanRideStep.driverDetail));
  }

  void highlightDriver(String id) {
    emit(state.copyWith(selectedDriverId: id));
  }

  void chooseSelectedDriver() {
    if (state.selectedDriver == null) return;
    emit(state.copyWith(step: UrbanRideStep.confirm));
  }

  void confirmRide() {
    _stopPoll();
    emit(state.copyWith(step: UrbanRideStep.confirmed, confirmedLocally: true));
  }

  void openLayers() {
    emit(state.copyWith(
      step: UrbanRideStep.layers,
      returnTo: state.step == UrbanRideStep.layers ? state.returnTo : state.step,
      draftLayerVisibility: state.layerVisibility,
    ));
  }

  void updateDraftLayers(LayerVisibility visibility) {
    emit(state.copyWith(draftLayerVisibility: visibility));
  }

  void resetDraftLayers() {
    emit(state.copyWith(draftLayerVisibility: LayerVisibility.reset));
  }

  void applyLayers() {
    emit(state.copyWith(
      layerVisibility: state.draftLayerVisibility,
      step: state.returnTo,
    ));
  }

  void toggleLegend() {
    emit(state.copyWith(legendExpanded: !state.legendExpanded));
  }

  void openIncident(TrafficLayer layer) {
    emit(state.copyWith(
      selectedIncident: layer,
      step: UrbanRideStep.incident,
      returnTo: state.step == UrbanRideStep.incident ? state.returnTo : state.step,
    ));
  }

  void seeAlternativeFromIncident() {
    emit(state.copyWith(step: UrbanRideStep.compareRoutes, returnTo: UrbanRideStep.tripSummary));
  }

  void recenter() {
    final target = state.userPosition ?? state.origin ?? kYaoundeCenter;
    emit(state.copyWith(center: target));
  }

  void resetToHome() {
    _stopPoll();
    emit(state.copyWith(
      step: UrbanRideStep.home,
      destination: null,
      destinationLabel: '',
      destinationQuery: '',
      geocodeResults: const [],
      geocodeFailed: false,
      geocoding: false,
      selectedDriverId: null,
      nearby: null,
      drivers: const [],
      confirmedLocally: false,
      selectedIncident: null,
      apiError: null,
    ));
  }

  bool _keepsPolling(UrbanRideStep step) {
    return step == UrbanRideStep.results ||
        step == UrbanRideStep.driverDetail ||
        step == UrbanRideStep.confirm ||
        step == UrbanRideStep.filters;
  }

  void _startPoll() {
    _poll?.cancel();
    _poll = Timer.periodic(pollInterval, (_) => refreshNearby());
  }

  void _stopPoll() {
    _poll?.cancel();
    _poll = null;
  }

  @override
  Future<void> close() {
    _geocodeDebounce?.cancel();
    _locationSub?.cancel();
    _stopPoll();
    return super.close();
  }
}
