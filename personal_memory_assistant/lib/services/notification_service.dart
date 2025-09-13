import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  NotificationService._internal() {
    try {
      tz.initializeTimeZones();
      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      );
      _flutterLocalNotificationsPlugin.initialize(initializationSettings).then((success) {
        if (success == true) {
          debugPrint('NotificationService initialized successfully.');
        } else {
          debugPrint('Failed to initialize NotificationService.');
        }
      }).catchError((error) {
        debugPrint('Error initializing NotificationService: $error');
      });
    } catch (e) {
      debugPrint('Exception in NotificationService constructor: $e');
    }
  }

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> requestPermissions() async {
    try {
      debugPrint('Requesting iOS notification permissions...');
      final iosImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        debugPrint('iOS notification permissions ${granted == true ? "granted" : "denied"}.');
      } else {
        debugPrint('iOS implementation not available (likely running on Android).');
      }
    } catch (e) {
      debugPrint('Error requesting iOS permissions: $e');
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      final now = DateTime.now();
      if (scheduledTime.isBefore(now)) {
        debugPrint('Scheduled time is in the past: $scheduledTime');
        return;
      }

      debugPrint('Scheduling notification: $title at $scheduledTime');
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel',
            'Task Reminders',
            channelDescription: 'Notifications for task reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('Notification scheduled with ID: $id');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<void> notifyAchievementUnlocked({
    required String achievementName,
  }) async {
    try {
      debugPrint('Scheduling achievement notification for: $achievementName');
      final now = DateTime.now();
      final id = now.millisecondsSinceEpoch % 1000000;
      await scheduleNotification(
        id: id,
        title: 'Achievement Unlocked!',
        body: 'Congratulations! You earned the $achievementName badge.',
        scheduledTime: now.add(const Duration(seconds: 2)),
      );
      debugPrint('Achievement notification scheduled.');
    } catch (e) {
      debugPrint('Error in notifyAchievementUnlocked: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      debugPrint('Canceling notification with ID: $id');
      await _flutterLocalNotificationsPlugin.cancel(id);
      debugPrint('Notification canceled.');
    } catch (e) {
      debugPrint('Error canceling notification: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      debugPrint('Canceling all notifications...');
      await _flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('All notifications canceled.');
    } catch (e) {
      debugPrint('Error canceling all notifications: $e');
    }
  }
}