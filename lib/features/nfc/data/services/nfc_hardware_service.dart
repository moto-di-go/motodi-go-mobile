import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';

/// Accès matériel NFC — lecture Android ; iOS forcé QR (parcours NFC masqué).
/// HCE peer-to-peer non supporté par nfc_manager → émission via QR.
@lazySingleton
class NfcHardwareService {
  bool get forceQrOnly => !kIsWeb && Platform.isIOS;

  Future<bool> isNfcAvailable() async {
    if (kIsWeb || forceQrOnly) return false;
    try {
      final availability = await NfcManager.instance.checkAvailability();
      return availability == NfcAvailability.enabled;
    } catch (_) {
      return false;
    }
  }

  /// Démarre une session lecture ; appelle [onToken] avec le payload texte trouvé.
  Future<void> startReaderSession({
    required void Function(String payload) onToken,
    required void Function(String message) onError,
  }) async {
    if (forceQrOnly) {
      onError('Sur iOS, utilisez le QR ou le collage manuel.');
      return;
    }
    final available = await isNfcAvailable();
    if (!available) {
      onError('NFC indisponible sur cet appareil.');
      return;
    }

    try {
      await NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso14443},
        onDiscovered: (NfcTag tag) async {
          try {
            final payload = _extractPayload(tag);
            if (payload == null || payload.isEmpty) {
              onError('Aucun jeton trouvé sur ce tag.');
              return;
            }
            onToken(payload);
            await NfcManager.instance.stopSession();
          } catch (_) {
            onError('Lecture NFC impossible.');
            await NfcManager.instance.stopSession();
          }
        },
      );
    } catch (_) {
      onError('Impossible de démarrer la session NFC.');
    }
  }

  Future<void> stopSession() async {
    try {
      await NfcManager.instance.stopSession();
    } catch (_) {}
  }

  /// HCE non disponible : bascule QR. Tentative symbolique pour UX Android.
  Future<void> startEmitWriteSession({
    required String signedToken,
    required void Function() onWritten,
    required void Function(String message) onError,
  }) async {
    onError('Émission HCE non disponible — utilisez le QR.');
  }

  String? _extractPayload(NfcTag tag) {
    if (!Platform.isAndroid) return null;
    final ndef = NdefAndroid.from(tag);
    final message = ndef?.cachedNdefMessage;
    if (message == null) return null;
    for (final record in message.records) {
      final payload = record.payload;
      if (payload.isEmpty) continue;
      // Text well-known : status byte + language + text
      final typeStr = String.fromCharCodes(record.type);
      if (typeStr == 'T' && payload.length > 1) {
        final status = payload[0];
        final langLen = status & 0x3F;
        if (payload.length > 1 + langLen) {
          return utf8.decode(payload.sublist(1 + langLen));
        }
      }
      try {
        return utf8.decode(payload);
      } catch (_) {}
    }
    return null;
  }
}
