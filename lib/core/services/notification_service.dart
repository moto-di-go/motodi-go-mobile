import 'dart:convert';
import 'dart:io' show Platform;

import 'package:chopper/chopper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/kyc/presentation/pages/kyc_pages.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';

typedef KycNotificationHandler = void Function(KycNotificationPayload payload);
typedef NotificationDeepLinkHandler = void Function(NotificationDeepLink link);

enum NotificationDeepLinkKind { kyc, booking, payment, trip, wallet, unknown }

class NotificationDeepLink {
  final NotificationDeepLinkKind kind;
  final String? bookingId;
  final String? tripId;
  final String? paymentTransactionId;
  final KycNotificationPayload? kycPayload;
  final Map<String, dynamic> data;

  const NotificationDeepLink({
    required this.kind,
    this.bookingId,
    this.tripId,
    this.paymentTransactionId,
    this.kycPayload,
    this.data = const {},
  });
}

@lazySingleton
class NotificationService {
  NotificationService(this._client);

  final ChopperClient _client;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  KycNotificationHandler? _onKycDecision;
  NotificationDeepLinkHandler? _onDeepLink;
  bool _tokenRefreshBound = false;

  Future<void> initialize({
    KycNotificationHandler? onKycDecision,
    NotificationDeepLinkHandler? onDeepLink,
  }) async {
    _onKycDecision = onKycDecision;
    _onDeepLink = onDeepLink;
    if (Firebase.apps.isEmpty) return;

    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        _dispatchPayload(response.payload);
      },
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) _handleOpenedMessage(initialMessage);

    _bindTokenRefresh();
  }

  Future<String?> getToken() => _messaging.getToken();

  /// Registers the current FCM token with the backend (CORE-NOTIF-001).
  /// Safe to call after login / session restore; failures are non-blocking.
  Future<void> registerTokenWithBackend() async {
    if (Firebase.apps.isEmpty) return;
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) return;

      final platform = _backendPlatform();
      if (platform == null) return;

      final response = await _client.post<Map<String, dynamic>, Map<String, dynamic>>(
        Uri.parse('/notifications/devices'),
        body: {'token': token, 'platform': platform},
      );
      if (!response.isSuccessful && kDebugMode) {
        debugPrint('FCM token register failed: ${response.statusCode}');
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('FCM token register skipped: $error');
      }
    }
  }

  void _bindTokenRefresh() {
    if (_tokenRefreshBound) return;
    _tokenRefreshBound = true;
    _messaging.onTokenRefresh.listen((_) {
      registerTokenWithBackend();
    });
  }

  String? _backendPlatform() {
    if (kIsWeb) return null;
    if (Platform.isAndroid) return 'ANDROID';
    if (Platform.isIOS) return 'IOS';
    return null;
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final link = deepLinkFromMessageData(message.data, notification: message.notification);
    if (link == null) return;
    const androidDetails = AndroidNotificationDetails(
      'motodigo_alerts',
      'Alertes Moto’di Go',
      channelDescription: 'Réservations, paiements, trajets et KYC',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());
    final title = message.notification?.title ?? message.data['title'] as String? ?? 'Moto’di Go';
    final body = message.notification?.body ?? message.data['body'] as String? ?? '';
    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      notificationDetails: details,
      payload: json.encode(message.data),
    );
  }

  void _handleOpenedMessage(RemoteMessage message) {
    final link = deepLinkFromMessageData(message.data, notification: message.notification);
    if (link == null) return;
    _emit(link);
  }

  void _dispatchPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final data = Map<String, dynamic>.from(json.decode(payload) as Map);
      final link = deepLinkFromMessageData(data);
      if (link != null) _emit(link);
    } catch (_) {
      // Legacy KYC-only local payload
      final kyc = _legacyKycFromJson(payload);
      if (kyc != null) {
        _emit(
          NotificationDeepLink(kind: NotificationDeepLinkKind.kyc, kycPayload: kyc, data: const {}),
        );
      }
    }
  }

  void _emit(NotificationDeepLink link) {
    if (link.kind == NotificationDeepLinkKind.kyc && link.kycPayload != null) {
      _onKycDecision?.call(link.kycPayload!);
    }
    _onDeepLink?.call(link);
  }

  static NotificationDeepLink? deepLinkFromMessageData(
    Map<String, dynamic> data, {
    RemoteNotification? notification,
  }) {
    final type = (data['type'] ?? data['eventType'] ?? '').toString().toUpperCase();
    final bookingId = data['bookingId']?.toString();
    final tripId = data['tripId']?.toString();
    final paymentId = data['paymentTransactionId']?.toString() ?? data['paymentId']?.toString();

    if (type == 'KYC_DECISION') {
      return NotificationDeepLink(
        kind: NotificationDeepLinkKind.kyc,
        kycPayload: KycNotificationPayload(
          title: notification?.title ?? data['title'] as String? ?? 'Statut KYC mis a jour',
          body: notification?.body ?? data['body'] as String? ?? '',
          status: ValidationStatus.fromApi(data['status'] as String?),
          reason: data['reason'] as String?,
          occurredAt: DateTime.tryParse(data['occurredAt'] as String? ?? '') ?? DateTime.now(),
        ),
        data: data,
      );
    }

    if (type.contains('TRIP') || type == 'STATUS_CHANGE' || (tripId != null && tripId.isNotEmpty)) {
      if (tripId != null && tripId.isNotEmpty) {
        return NotificationDeepLink(
          kind: NotificationDeepLinkKind.trip,
          tripId: tripId,
          bookingId: bookingId,
          data: data,
        );
      }
    }

    if (type == 'PAYMENT' || type.contains('PAYMENT')) {
      return NotificationDeepLink(
        kind: NotificationDeepLinkKind.payment,
        bookingId: bookingId,
        paymentTransactionId: paymentId,
        data: data,
      );
    }

    if (bookingId != null && bookingId.isNotEmpty) {
      return NotificationDeepLink(
        kind: NotificationDeepLinkKind.booking,
        bookingId: bookingId,
        tripId: tripId,
        data: data,
      );
    }

    if (type == 'SUBSCRIPTION' ||
        type == 'CONFIRMATION' ||
        type == 'CANCELLATION' ||
        type == 'DEPARTURE_REMINDER') {
      return NotificationDeepLink(
        kind: bookingId != null && bookingId.isNotEmpty
            ? NotificationDeepLinkKind.booking
            : NotificationDeepLinkKind.wallet,
        bookingId: bookingId,
        data: data,
      );
    }

    return null;
  }

  KycNotificationPayload? _legacyKycFromJson(String payload) {
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
}
