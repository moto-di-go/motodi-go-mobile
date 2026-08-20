import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_geo.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_models.dart';

class UrbanRideState extends Equatable {
  final UrbanRideStep step;
  final UrbanRideStep returnTo;
  final LatLng center;
  final LatLng? userPosition;
  final LatLng? origin;
  final LatLng? destination;
  final String originLabel;
  final String destinationQuery;
  final String destinationLabel;
  final bool locating;
  final String? locationError;
  final String? apiError;
  final double? walletBalance;
  final List<UrbanPlace> popularPlaces;
  final bool popularPlacesDemo;
  final List<UrbanPlace> geocodeResults;
  final bool geocodeFailed;
  final bool geocoding;
  final List<DestinationHistoryEntry> history;
  final FareEstimate? estimate;
  final List<RouteOption> routeOptions;
  final RouteOptionKind selectedKind;
  final bool routeOptionsDemo;
  final NearbySearchResult? nearby;
  final List<UrbanDriverCard> drivers;
  final String? selectedDriverId;
  final UrbanFilters filters;
  final UrbanFilters draftFilters;
  final List<TrafficLayer> layers;
  final DateTime? layersFetchedAt;
  final LayerVisibility layerVisibility;
  final LayerVisibility draftLayerVisibility;
  final bool legendExpanded;
  final TrafficLayer? selectedIncident;
  final bool searching;
  final bool confirmedLocally;

  const UrbanRideState({
    this.step = UrbanRideStep.home,
    this.returnTo = UrbanRideStep.home,
    this.center = kYaoundeCenter,
    this.userPosition,
    this.origin,
    this.destination,
    this.originLabel = 'Ma position',
    this.destinationQuery = '',
    this.destinationLabel = '',
    this.locating = false,
    this.locationError,
    this.apiError,
    this.walletBalance,
    this.popularPlaces = const [],
    this.popularPlacesDemo = false,
    this.geocodeResults = const [],
    this.geocodeFailed = false,
    this.geocoding = false,
    this.history = const [],
    this.estimate,
    this.routeOptions = const [],
    this.selectedKind = RouteOptionKind.recommended,
    this.routeOptionsDemo = false,
    this.nearby,
    this.drivers = const [],
    this.selectedDriverId,
    this.filters = const UrbanFilters(),
    this.draftFilters = const UrbanFilters(),
    this.layers = const [],
    this.layersFetchedAt,
    this.layerVisibility = const LayerVisibility(),
    this.draftLayerVisibility = const LayerVisibility(),
    this.legendExpanded = true,
    this.selectedIncident,
    this.searching = false,
    this.confirmedLocally = false,
  });

  RouteOption? get selectedOption {
    for (final option in routeOptions) {
      if (option.kind == selectedKind) return option;
    }
    return routeOptions.isEmpty ? null : routeOptions.first;
  }

  UrbanDriverCard? get selectedDriver {
    for (final driver in drivers) {
      if (driver.id == selectedDriverId) return driver;
    }
    return null;
  }

  FareBreakdown? get selectedBreakdown => null;

  double get selectedAmount => selectedOption?.amountFcfa ?? estimate?.amountFcfa ?? 0;

  double get selectedDistance => selectedOption?.distanceKm ?? estimate?.distanceKm ?? 0;

  int get selectedDuration => selectedOption?.durationMinutes ?? estimate?.durationMinutes ?? 0;

  String get selectedPolyline => selectedOption?.polyline ?? estimate?.polyline ?? '';

  List<TrafficLayer> get visibleLayers => layers.where(layerVisibility.allows).toList();

  bool get hasTrafficBanner {
    return visibleLayers.any((layer) {
      final type = layer.type.toUpperCase();
      return type == 'CONGESTION' ||
          type == 'ROADWORK' ||
          type == 'DAMAGED_ROAD' ||
          layer.severity.toUpperCase() == 'HIGH' ||
          layer.severity.toUpperCase() == 'CRITICAL';
    });
  }

  List<UrbanPlace> get visiblePlaces {
    final query = destinationQuery.trim();
    if (query.isEmpty) return popularPlaces;
    if (geocodeResults.isNotEmpty) return geocodeResults;
    if (!geocodeFailed) return const [];
    final needle = query.toLowerCase();
    return popularPlaces.where((place) => place.label.toLowerCase().contains(needle)).toList();
  }

  bool get visiblePlacesDemo {
    final query = destinationQuery.trim();
    if (query.isEmpty) return popularPlacesDemo;
    if (geocodeResults.isNotEmpty) return false;
    return geocodeFailed && popularPlacesDemo;
  }

  String get layersFreshness {
    if (layers.isEmpty) return 'Aucune couche trafic';
    if (layers.any((layer) => layer.isStale())) return 'Données anciennes';
    DateTime? newest;
    for (final layer in layers) {
      final stamp = layer.updatedAt ?? layer.fetchedAt;
      if (newest == null || stamp.isAfter(newest)) newest = stamp;
    }
    final reference = newest ?? layersFetchedAt;
    if (reference == null) return 'Couches trafic';
    final minutes = DateTime.now().difference(reference).inMinutes;
    if (minutes <= 0) return "Mis à jour à l'instant";
    return 'Mis à jour il y a $minutes min';
  }

  UrbanRideState copyWith({
    UrbanRideStep? step,
    UrbanRideStep? returnTo,
    LatLng? center,
    LatLng? userPosition,
    LatLng? origin,
    Object? destination = _unset,
    String? originLabel,
    String? destinationQuery,
    String? destinationLabel,
    bool? locating,
    Object? locationError = _unset,
    Object? apiError = _unset,
    Object? walletBalance = _unset,
    List<UrbanPlace>? popularPlaces,
    bool? popularPlacesDemo,
    List<UrbanPlace>? geocodeResults,
    bool? geocodeFailed,
    bool? geocoding,
    List<DestinationHistoryEntry>? history,
    Object? estimate = _unset,
    List<RouteOption>? routeOptions,
    RouteOptionKind? selectedKind,
    bool? routeOptionsDemo,
    Object? nearby = _unset,
    List<UrbanDriverCard>? drivers,
    Object? selectedDriverId = _unset,
    UrbanFilters? filters,
    UrbanFilters? draftFilters,
    List<TrafficLayer>? layers,
    DateTime? layersFetchedAt,
    LayerVisibility? layerVisibility,
    LayerVisibility? draftLayerVisibility,
    bool? legendExpanded,
    Object? selectedIncident = _unset,
    bool? searching,
    bool? confirmedLocally,
  }) {
    return UrbanRideState(
      step: step ?? this.step,
      returnTo: returnTo ?? this.returnTo,
      center: center ?? this.center,
      userPosition: userPosition ?? this.userPosition,
      origin: origin ?? this.origin,
      destination: identical(destination, _unset) ? this.destination : destination as LatLng?,
      originLabel: originLabel ?? this.originLabel,
      destinationQuery: destinationQuery ?? this.destinationQuery,
      destinationLabel: destinationLabel ?? this.destinationLabel,
      locating: locating ?? this.locating,
      locationError: identical(locationError, _unset)
          ? this.locationError
          : locationError as String?,
      apiError: identical(apiError, _unset) ? this.apiError : apiError as String?,
      walletBalance: identical(walletBalance, _unset)
          ? this.walletBalance
          : walletBalance as double?,
      popularPlaces: popularPlaces ?? this.popularPlaces,
      popularPlacesDemo: popularPlacesDemo ?? this.popularPlacesDemo,
      geocodeResults: geocodeResults ?? this.geocodeResults,
      geocodeFailed: geocodeFailed ?? this.geocodeFailed,
      geocoding: geocoding ?? this.geocoding,
      history: history ?? this.history,
      estimate: identical(estimate, _unset) ? this.estimate : estimate as FareEstimate?,
      routeOptions: routeOptions ?? this.routeOptions,
      selectedKind: selectedKind ?? this.selectedKind,
      routeOptionsDemo: routeOptionsDemo ?? this.routeOptionsDemo,
      nearby: identical(nearby, _unset) ? this.nearby : nearby as NearbySearchResult?,
      drivers: drivers ?? this.drivers,
      selectedDriverId: identical(selectedDriverId, _unset)
          ? this.selectedDriverId
          : selectedDriverId as String?,
      filters: filters ?? this.filters,
      draftFilters: draftFilters ?? this.draftFilters,
      layers: layers ?? this.layers,
      layersFetchedAt: layersFetchedAt ?? this.layersFetchedAt,
      layerVisibility: layerVisibility ?? this.layerVisibility,
      draftLayerVisibility: draftLayerVisibility ?? this.draftLayerVisibility,
      legendExpanded: legendExpanded ?? this.legendExpanded,
      selectedIncident: identical(selectedIncident, _unset)
          ? this.selectedIncident
          : selectedIncident as TrafficLayer?,
      searching: searching ?? this.searching,
      confirmedLocally: confirmedLocally ?? this.confirmedLocally,
    );
  }

  @override
  List<Object?> get props => [
    step,
    returnTo,
    center,
    userPosition,
    origin,
    destination,
    originLabel,
    destinationQuery,
    destinationLabel,
    locating,
    locationError,
    apiError,
    walletBalance,
    popularPlaces,
    popularPlacesDemo,
    geocodeResults,
    geocodeFailed,
    geocoding,
    history,
    estimate,
    routeOptions,
    selectedKind,
    routeOptionsDemo,
    nearby,
    drivers,
    selectedDriverId,
    filters,
    draftFilters,
    layers,
    layersFetchedAt,
    layerVisibility,
    draftLayerVisibility,
    legendExpanded,
    selectedIncident,
    searching,
    confirmedLocally,
  ];
}

const Object _unset = Object();
