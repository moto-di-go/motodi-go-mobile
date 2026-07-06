import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

// Rôle : Gère les notifications push Firebase et les notifications locales.
// Dépendances : firebase_messaging, flutter_local_notifications
// Désactiver : supprimer l'appel getIt<NotificationService>().initialize() dans main.dart
//               et retirer firebase_messaging + flutter_local_notifications de pubspec.yaml
@lazySingleton
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Demande de permission
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // Configuration des notifications locales Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _localNotifications.initialize(initSettings);

    // Écoute des messages en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // TODO: [TEMPLATE] Configurer les topics, le stockage du token FCM, etc.
  }

  Future<String?> getToken() => _messaging.getToken();

  void _handleForegroundMessage(RemoteMessage message) {
    // TODO: [TEMPLATE] Afficher une notification locale ici
  }
}
