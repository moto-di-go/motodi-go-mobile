import 'package:latlong2/latlong.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_geo.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_models.dart';

const kYaoundePopularPlaces = <UrbanPlace>[
  UrbanPlace(id: 'bastos', label: 'Bastos', point: LatLng(3.8905, 11.5108), isDemo: true),
  UrbanPlace(id: 'mvan', label: 'Mvog-Ada / Mvan', point: LatLng(3.8522, 11.5286), isDemo: true),
  UrbanPlace(id: 'nlongkak', label: 'Nlongkak', point: LatLng(3.8794, 11.5189), isDemo: true),
  UrbanPlace(id: 'essos', label: 'Essos', point: LatLng(3.8668, 11.5412), isDemo: true),
  UrbanPlace(id: 'mokolo', label: 'Mokolo', point: LatLng(3.8746, 11.5021), isDemo: true),
  UrbanPlace(id: 'etoudi', label: 'Etoudi', point: LatLng(3.9214, 11.5218), isDemo: true),
  UrbanPlace(id: 'odza', label: 'Odza', point: LatLng(3.8224, 11.5184), isDemo: true),
  UrbanPlace(id: 'biyem-assi', label: 'Biyem-Assi', point: LatLng(3.8376, 11.4859), isDemo: true),
];

const _kDemoNames = ['Jean M.', 'Paul K.', 'Aïcha N.', 'Serge T.', 'Marie B.', 'Hassan O.'];
const _kDemoBikes = ['Yamaha Crypton', 'Honda Wave', 'Suzuki Address'];

UrbanDriverCard enrichNearbyDriver(NearbyDriver driver, {double? fallbackPrice}) {
  final hasProfile =
      (driver.displayName?.trim().isNotEmpty ?? false) &&
      driver.rating != null &&
      (driver.vehicleLabel?.trim().isNotEmpty ?? false);
  final hash = driver.driverProfileId.hashCode.abs();
  final name = driver.displayName?.trim().isNotEmpty == true
      ? driver.displayName!.trim()
      : _kDemoNames[hash % _kDemoNames.length];
  final rating = driver.rating ?? (4.0 + (hash % 10) / 10);
  final trips = driver.tripCount ?? (80 + hash % 420);
  final vehicle = driver.vehicleLabel?.trim().isNotEmpty == true
      ? driver.vehicleLabel!.trim()
      : _kDemoBikes[hash % _kDemoBikes.length];
  final plate = driver.plate?.trim().isNotEmpty == true
      ? driver.plate!.trim()
      : 'LT ${1000 + hash % 9000} A';
  final eta = driver.approachDistanceKm <= 0 ? 3 : estimateUrbanMinutes(driver.approachDistanceKm);
  return UrbanDriverCard(
    id: driver.driverProfileId,
    name: name,
    rating: rating,
    tripCount: trips,
    vehicleLabel: vehicle,
    plate: plate,
    documentsVerified: driver.documentsVerified ?? true,
    cniVerified: driver.documentsVerified ?? true,
    etaMinutes: eta,
    priceFcfa: driver.estimatedAmountFcfa ?? fallbackPrice ?? 800,
    availability: driver.availability,
    lat: driver.lat,
    lon: driver.lon,
    approachDistanceKm: driver.approachDistanceKm,
    profileIsDemo: !hasProfile,
  );
}

List<UrbanDriverCard> enrichNearbyDrivers(List<NearbyDriver> items, {double? fallbackPrice}) {
  return items.map((item) => enrichNearbyDriver(item, fallbackPrice: fallbackPrice)).toList();
}
