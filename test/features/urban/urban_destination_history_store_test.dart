import 'package:flutter_test/flutter_test.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_destination_history_store.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persists destinations locally and deduplicates by label/coords', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = UrbanDestinationHistoryStore(prefs);

    await store.add(
      DestinationHistoryEntry(label: 'Bastos', lat: 3.89, lon: 11.51, savedAt: DateTime(2026, 8, 15)),
    );
    await store.add(
      DestinationHistoryEntry(label: 'Essos', lat: 3.86, lon: 11.54, savedAt: DateTime(2026, 8, 15, 1)),
    );
    final next = await store.add(
      DestinationHistoryEntry(label: 'Bastos', lat: 3.89, lon: 11.51, savedAt: DateTime(2026, 8, 15, 2)),
    );

    expect(next, hasLength(2));
    expect(next.first.label, 'Bastos');
    expect(store.load().map((e) => e.label), ['Bastos', 'Essos']);
  });
}
