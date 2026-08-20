import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/kyc/presentation/pages/kyc_pages.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';

typedef KycNotificationHandler = void Function(KycNotificationPayload payload);

@lazySingleton
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  KycNotificationHandler? _onKycDecision;

  Future<void> initialize({KycNotificationHandler? onKycDecision}) async {
    _onKycDecision = onKycDecision;
    if (Firebase.apps.isEmpty) return;

    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = _payloadFromJson(response.payload);
        if (payload != null) _onKycDecision?.call(payload);
      },
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) _handleOpenedMessage(initialMessage);
  }

  Future<String?> getToken() => _messaging.getToken();

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final payload = _payloadFromMessage(message);
    if (payload == null) return;
    const androidDetails = AndroidNotificationDetails(
      'kyc_decisions',
      'Decisions KYC',
      channelDescription: 'Notifications de validation des documents KYC',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());
    await _localNotifications.show(
      id: payload.occurredAt.millisecondsSinceEpoch.remainder(100000),
      title: payload.title,
      body: payload.body,
      notificationDetails: details,
      payload: json.encode(_payloadToJson(payload)),
    );
  }

  void _handleOpenedMessage(RemoteMessage message) {
    final payload = _payloadFromMessage(message);
    if (payload != null) _onKycDecision?.call(payload);
  }

  KycNotificationPayload? _payloadFromMessage(RemoteMessage message) {
    final type = message.data['type'] ?? message.data['eventType'];
    if (type != 'KYC_DECISION') return null;
    return KycNotificationPayload(
      title:
          message.notification?.title ??
          message.data['title'] as String? ??
          'Statut KYC mis a jour',
      body: message.notification?.body ?? message.data['body'] as String? ?? '',
      status: ValidationStatus.fromApi(message.data['status'] as String?),
      reason: message.data['reason'] as String?,
      occurredAt: DateTime.tryParse(message.data['occurredAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  KycNotificationPayload? _payloadFromJson(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final jsonPayload = Map<String, dynamic>.from(json.decode(payload) as Map);
      return KycNotificationPayload(
        title: jsonPayload['title'] as String? ?? 'Statut KYC mis a jour',
        body: jsonPayload['body'] as String? ?? '',
        status: ValidationStatus.fromApi(jsonPayload['status'] as String?),
        reason: jsonPayload['reason'] as String?,
        occurredAt: DateTime.tryParse(jsonPayload['occurredAt'] as String? ?? '') ?? DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _payloadToJson(KycNotificationPayload payload) {
    return {
      'title': payload.title,
      'body': payload.body,
      'status': payload.status.apiValue,
      if (payload.reason != null) 'reason': payload.reason,
      'occurredAt': payload.occurredAt.toIso8601String(),
    };
  }
}
