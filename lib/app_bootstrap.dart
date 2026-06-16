import 'notification_service.dart';

Future<void> bootstrapApp() async {
  await registerBackgroundMessaging();
  await NotificationService.instance.initialize();
}
