import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/nfc/data/models/nfc_models.dart';
import 'package:motodi_go_mobile/features/nfc/domain/entities/nfc_entities.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class NfcLocalDataSource {
  Future<List<PendingNfcPayment>> listPending();

  Future<void> savePending(PendingNfcPayment payment);

  Future<void> updatePending(PendingNfcPayment payment);

  Future<void> removePending(String id);
}

@LazySingleton(as: NfcLocalDataSource)
class NfcLocalDataSourceImpl implements NfcLocalDataSource {
  static const _key = 'nfc_pending_payments_v1';

  final SharedPreferences _prefs;

  NfcLocalDataSourceImpl(this._prefs);

  @override
  Future<List<PendingNfcPayment>> listPending() async {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    final list = jsonDecode(raw) as List? ?? const [];
    return list
        .map((item) => PendingNfcPaymentModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .map((m) => m.toEntity())
        .toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }

  @override
  Future<void> savePending(PendingNfcPayment payment) async {
    final current = await listPending();
    final next = [payment, ...current.where((e) => e.id != payment.id)];
    await _persist(next);
  }

  @override
  Future<void> updatePending(PendingNfcPayment payment) async {
    final current = await listPending();
    final next = current.map((e) => e.id == payment.id ? payment : e).toList();
    await _persist(next);
  }

  @override
  Future<void> removePending(String id) async {
    final current = await listPending();
    await _persist(current.where((e) => e.id != id).toList());
  }

  Future<void> _persist(List<PendingNfcPayment> items) async {
    final encoded = jsonEncode(
      items.map((e) => PendingNfcPaymentModel.fromEntity(e).toJson()).toList(),
    );
    await _prefs.setString(_key, encoded);
  }
}
