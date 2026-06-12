import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'in_app_notification_popup.dart';
import 'notification_category.dart';

final GlobalKey<NavigatorState> hackPrixNavigatorKey =
    GlobalKey<NavigatorState>();

typedef NotificationNavigationHandler = void Function(BuildContext context);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.setupLocalNotifications();
  await NotificationService.displayNotification(message);
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'high_importance_channel',
        'HackPrix Notifications',
        description: 'Announcements and event updates from HackPrix.',
        importance: Importance.high,
      );

  NotificationNavigationHandler? onViewUpdates;

  Future<void> initialize() async {
    await setupLocalNotifications();
    await _requestPermissions();
    await _saveCurrentToken();
    _listenForTokenRefresh();
    _listenForForegroundMessages();
    _listenForBackgroundOpen();

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToUpdates();
      });
    }
  }

  static Future<void> setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);
  }

  Future<void> _requestPermissions() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('FCM permission status: ${settings.authorizationStatus}');

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> _saveCurrentToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) {
      debugPrint('FCM Token: unavailable');
      return;
    }

    await _saveTokenToFirestore(token);
  }

  void _listenForTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen(_saveTokenToFirestore);
  }

  Future<void> _saveTokenToFirestore(String token) async {
    debugPrint('FCM Token: $token');

    await FirebaseFirestore.instance.collection('users').doc(token).set({
      'fcmToken': token,
    });
  }

  void _listenForForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground FCM message received: ${message.messageId}');
      _showInAppPopup(message);
    });
  }

  void _listenForBackgroundOpen() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification opened app: ${message.messageId}');
      _navigateToUpdates();
    });
  }

  void _navigateToUpdates() {
    final context = hackPrixNavigatorKey.currentContext;
    if (context == null) return;

    if (onViewUpdates != null) {
      onViewUpdates!(context);
      return;
    }

    Navigator.of(context).pushNamed('/announcements');
  }

  void _showInAppPopup(RemoteMessage message) {
    final context = hackPrixNavigatorKey.currentContext;
    if (context == null) return;

    final parsed = _parseMessage(message);
    if (parsed == null) return;

    InAppNotificationPopup.show(
      context,
      title: parsed.title,
      body: parsed.body,
      category: parsed.category,
      onViewUpdates: _navigateToUpdates,
    );
  }

  static _ParsedNotification? _parseMessage(RemoteMessage message) {
    final notification = message.notification;
    final category = NotificationCategory.fromValue(message.data['category']);
    final dataMessage = message.data['message'];
    final title = notification?.title ??
        message.data['title'] ??
        category.popupTitle;
    final body = notification?.body ??
        message.data['body'] ??
        dataMessage ??
        'You have a new update.';

    if (title.isEmpty && body.isEmpty) return null;

    return _ParsedNotification(
      title: title,
      body: body,
      category: category,
    );
  }

  static Future<void> displayNotification(RemoteMessage message) async {
    final parsed = _parseMessage(message);
    if (parsed == null) return;

    final androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    await _localNotifications.show(
      message.hashCode,
      parsed.title,
      parsed.body,
      NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data.toString(),
    );
  }
}

class _ParsedNotification {
  final String title;
  final String body;
  final NotificationCategory category;

  const _ParsedNotification({
    required this.title,
    required this.body,
    required this.category,
  });
}
