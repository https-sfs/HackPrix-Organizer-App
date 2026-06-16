import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> hackPrixNavigatorKey =
    GlobalKey<NavigatorState>();

typedef NotificationNavigationHandler = void Function(BuildContext context);

Future<void> firebaseMessagingBackgroundHandler(dynamic message) async {}

Future<void> registerBackgroundMessaging() async {}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  NotificationNavigationHandler? onViewUpdates;

  Future<void> initialize() async {}

  static Future<void> setupLocalNotifications() async {}

  static Future<void> displayNotification(dynamic message) async {}
}
