import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_destination_history_store.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_estimate_parser.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_location_source.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_models.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_remote_datasource.dart';
import 'package:motodi_go_mobile/features/urban/presentation/urban_ride_cubit.dart';
import 'package:motodi_go_mobile/features/urban/presentation/urban_ride_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockUrbanRemote extends Mock implements UrbanRemoteDataSource {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockUrbanRemote remote;
  late UrbanDestinationHistoryStore history;
  late UrbanLocationSource location;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    remote = MockUrbanRemote();
    history = UrbanDestinationHistoryStore(await SharedPreferences.getInstance());
    location = _FixedLocationSource(const LatLng(3.868, 11.516));
    when(() => remote.wallet()).thenAnswer((_) async => const WalletSummary(currentBalance: 4500));
    when(() => remote.popularPlaces()).thenAnswer((_) async => null);
    when(() => remote.geocode(any(), lat: any(named: 'lat'), lon: any(named: 'lon'))).thenAnswer((_) async => null);
    when(() => remote.layers()).thenAnswer((_) async => const []);
    when(() => remote.reverseGeocode(lat: any(named: 'lat'), lon: any(named: 'lon')))
        .thenAnswer((_) async => null);
  });

  UrbanRideCubit buildCubit() {
    return UrbanRideCubit(
      remote: remote,
      history: history,
      location: location,
      pollInterval: const Duration(hours: 1),
      searchMinDuration: Duration.zero,
    );
  }

  blocTest<UrbanRideCubit, UrbanRideState>(
    'builds demo route options when estimate has no options[]',
    build: buildCubit,
    seed: () => const UrbanRideState(
      origin: LatLng(3.868, 11.516),
      originLabel: 'Ma position',
    ),
    setUp: () {
      when(
        () => remote.estimate(
          originLat: any(named: 'originLat'),
          originLon: any(named: 'originLon'),
          destinationLat: any(named: 'destinationLat'),
          destinationLon: any(named: 'destinationLon'),
        ),
      ).thenAnswer(
        (_) async => FareEstimate.fromJson({
          'id': 'e1',
          'amountFcfa': 800,
          'distanceKm': 3.1,
          'durationMinutes': 11,
          'appliedRulesTrace': 'base 300 + 3.100km*150, arrondi, night=1, weather=1 (precip=0mm)',
          'polyline': 'LINESTRING(11.516 3.868, 11.511 3.890)',
        }),
      );
    },
    act: (cubit) => cubit.selectDestination(
      label: 'Bastos',
      point: const LatLng(3.8905, 11.5108),
    ),
    wait: const Duration(milliseconds: 20),
    expect: () => [
      isA<UrbanRideState>().having((s) => s.step, 'step', UrbanRideStep.calculating),
      isA<UrbanRideState>().having((s) => s.history, 'history', isNotEmpty),
      isA<UrbanRideState>()
          .having((s) => s.step, 'step', UrbanRideStep.tripSummary)
          .having((s) => s.routeOptions, 'options', hasLength(3))
          .having((s) => s.routeOptionsDemo, 'demo', isTrue)
          .having((s) => s.selectedAmount, 'amount', 800),
    ],
  );

  blocTest<UrbanRideCubit, UrbanRideState>(
    'applies client filters without a new nearby query when radius is unchanged',
    build: buildCubit,
    seed: () => const UrbanRideState(
      step: UrbanRideStep.results,
      origin: LatLng(3.868, 11.516),
      nearby: NearbySearchResult(
        items: [
          NearbyDriver(
            driverProfileId: 'd1',
            lat: 3.87,
            lon: 11.52,
            approachDistanceKm: 0.3,
            availability: 'AVAILABLE',
            estimatedAmountFcfa: 700,
          ),
          NearbyDriver(
            driverProfileId: 'd2',
            lat: 3.86,
            lon: 11.51,
            approachDistanceKm: 0.5,
            availability: 'AVAILABLE',
            estimatedAmountFcfa: 1200,
          ),
        ],
        radiusKm: 2,
      ),
      drivers: [],
      draftFilters: UrbanFilters(maxPriceFcfa: 800),
    ),
    act: (cubit) => cubit.applyFilters(),
    expect: () => [
      isA<UrbanRideState>().having((s) => s.step, 'step', UrbanRideStep.searching),
      isA<UrbanRideState>()
          .having((s) => s.step, 'step', UrbanRideStep.results)
          .having((s) => s.drivers, 'drivers', hasLength(1))
          .having((s) => s.drivers.first.priceFcfa, 'price', 700),
    ],
    verify: (_) {
      verifyNever(
        () => remote.nearby(
          lat: any(named: 'lat'),
          lon: any(named: 'lon'),
          radiusKm: any(named: 'radiusKm'),
          destLat: any(named: 'destLat'),
          destLon: any(named: 'destLon'),
        ),
      );
    },
  );

  blocTest<UrbanRideCubit, UrbanRideState>(
    'uses API options[] without demo banner when the backend returns them',
    build: buildCubit,
    seed: () => const UrbanRideState(
      origin: LatLng(3.868, 11.516),
      originLabel: 'Ma position',
    ),
    setUp: () {
      when(
        () => remote.estimate(
          originLat: any(named: 'originLat'),
          originLon: any(named: 'originLon'),
          destinationLat: any(named: 'destinationLat'),
          destinationLon: any(named: 'destinationLon'),
        ),
      ).thenAnswer(
        (_) async => FareEstimate.fromJson({
          'id': '7b1d2c3a-4e5f-6789-abcd-ef0123456789',
          'amountFcfa': 850,
          'distanceKm': 3.2,
          'durationMinutes': 10,
          'polyline': 'LINESTRING(11.516 3.868, 11.511 3.890)',
          'breakdown': {
            'baseFcfa': 300,
            'distanceKm': 3.2,
            'pricePerKmFcfa': 150,
            'distanceAmountFcfa': 480,
            'nightMultiplier': 1,
            'weatherMultiplier': 1,
            'nightWeatherApplicable': false,
            'roundingFcfa': 70,
            'totalFcfa': 850,
          },
          'options': [
            {
              'kind': 'RECOMMENDED',
              'label': 'Évite routes dégradées',
              'degraded': false,
              'distanceKm': 3.2,
              'durationMinutes': 10,
              'amountFcfa': 850,
              'polyline': 'LINESTRING(11.516 3.868, 11.511 3.890)',
            },
            {
              'kind': 'FASTEST',
              'label': 'Plus rapide',
              'degraded': true,
              'distanceKm': 3.0,
              'durationMinutes': 8,
              'amountFcfa': 900,
              'polyline': 'LINESTRING(11.516 3.868, 11.520 3.880, 11.511 3.890)',
            },
          ],
        }),
      );
    },
    act: (cubit) => cubit.selectDestination(
      label: 'Bastos',
      point: const LatLng(3.8905, 11.5108),
    ),
    wait: const Duration(milliseconds: 20),
    expect: () => [
      isA<UrbanRideState>().having((s) => s.step, 'step', UrbanRideStep.calculating),
      isA<UrbanRideState>().having((s) => s.history, 'history', isNotEmpty),
      isA<UrbanRideState>()
          .having((s) => s.step, 'step', UrbanRideStep.tripSummary)
          .having((s) => s.routeOptions, 'options', hasLength(2))
          .having((s) => s.routeOptionsDemo, 'demo', isFalse)
          .having((s) => s.selectedAmount, 'amount', 850)
          .having(
            (s) => resolveFareBreakdown(s.estimate, selectedAmount: s.selectedAmount).isDemo,
            'breakdownDemo',
            isFalse,
          )
          .having(
            (s) => resolveFareBreakdown(s.estimate, selectedAmount: s.selectedAmount).base,
            'base',
            300,
          ),
    ],
  );
}

class _FixedLocationSource implements UrbanLocationSource {
  final LatLng point;
  _FixedLocationSource(this.point);

  @override
  Future<UrbanLocationResult> currentPosition() async {
    return UrbanLocationResult(position: point);
  }

  @override
  Stream<UrbanLocationResult> watchPosition() => const Stream.empty();
}
