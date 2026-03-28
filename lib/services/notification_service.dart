import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  /// Requests POST_NOTIFICATIONS permission on Android 13+.
  /// Returns true if granted.
  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return false;
    final granted = await android.requestNotificationsPermission();
    return granted ?? false;
  }

  static Future<void> cancelUpdateNotification() async {
    await init();
    await _plugin.cancel(1001);
  }

  static Future<void> showUpdateNotification(String version) async {
    await init();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'precision_updates',
        'App Updates',
        channelDescription:
            'Notifies when a new version of Precision is available',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      ),
    );
    await _plugin.show(
      1001,
      'Precision v$version is available!',
      'A new update is ready. Visit GitHub to download it.',
      details,
    );
  }
}
