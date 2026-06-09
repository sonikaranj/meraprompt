import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:get_storage/get_storage.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _lastAppExitKey = 'last_app_exit_time';

  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );
  }

  // App exit hone ke time ko store kare
  void recordAppExit() {
    final now = DateTime.now().millisecondsSinceEpoch;
    GetStorage().write(_lastAppExitKey, now);
  }

  // 1 hour baad notification schedule kare
  Future<void> scheduleReturnNotification() async {
    final box = GetStorage();
    final lastExitTime = box.read(_lastAppExitKey) as int?;

    if (lastExitTime == null) return;

    final exitDateTime = DateTime.fromMillisecondsSinceEpoch(lastExitTime);
    final now = DateTime.now();
    final difference = now.difference(exitDateTime);

    // Agar 1 hour se zyada time ho gaya, to notification ek minute baad schedule karo
    if (difference.inMinutes >= 60) {
      await _scheduleNotificationIn(1);
    }
  }

  Future<void> _scheduleNotificationIn(int minutes) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id: 0,
      title: 'MK EDIT',
      body: 'Welcome back! Discover new AI prompts and creative ideas.',
      scheduledDate: tz.TZDateTime.now(tz.local).add(Duration(minutes: minutes)),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'mk_edit_channel',
          'MK EDIT Notifications',
          channelDescription: 'Notifications from MK EDIT app',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
    );
  }

  // Agar app 1 hour baad open ho to notification bhejo
  void checkAndNotifyIfAppClosedFor1Hour() {
    final box = GetStorage();
    final lastExitTime = box.read(_lastAppExitKey) as int?;

    if (lastExitTime == null) {
      recordAppExit();
      return;
    }

    final exitDateTime = DateTime.fromMillisecondsSinceEpoch(lastExitTime);
    final now = DateTime.now();
    final difference = now.difference(exitDateTime);

    if (difference.inHours >= 1) {
      _showImmediateNotification();
      recordAppExit(); // Reset timer
    } else {
      recordAppExit();
    }
  }

  Future<void> _showImmediateNotification() async {
    await _flutterLocalNotificationsPlugin.show(
      id: 0,
      title: 'MK EDIT',
      body: 'Welcome back! Check out trending new prompts and get inspired.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'mk_edit_channel',
          'MK EDIT Notifications',
          channelDescription: 'Notifications from MK EDIT app',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
        ),
      ),
    );
  }
}
