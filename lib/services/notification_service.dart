import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // Initialize notifications for both Android and iOS
  Future<void> initialize(BuildContext context) async {
    try {
      tz.initializeTimeZones();
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      final InitializationSettings initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(initializationSettings);

      // Request iOS permissions
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showNotification(context, message);
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to initialize notifications'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // Background message handler
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Background handling can be extended if needed
    debugPrint('Handling background message: ${message.messageId}');
  }

  // Show a notification from a Firebase message
  Future<void> _showNotification(BuildContext context, RemoteMessage message) async {
    try {
      final colorScheme = Theme.of(context).colorScheme;
      final androidDetails = AndroidNotificationDetails(
        'profocus_channel',
        'ProFocus Notifications',
        channelDescription: 'General notifications for ProFocus app',
        importance: Importance.max,
        priority: Priority.high,
        color: colorScheme.primary,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
        showProgress: false,
      );
      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      final platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        message.messageId.hashCode,
        message.notification?.title ?? 'ProFocus',
        message.notification?.body ?? 'You have a new notification',
        platformDetails,
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to show notification'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // Schedule a task reminder
  Future<void> scheduleTaskReminder(String taskId, String title, DateTime deadline) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        'task_channel',
        'Task Reminders',
        channelDescription: 'Reminders for upcoming tasks',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('task_reminder_sound'),
      );
      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      final platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        taskId.hashCode,
        'Task Reminder: $title',
        'Your task is due soon!',
        tz.TZDateTime.from(deadline, tz.local),
        platformDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Error scheduling task reminder: $e');
    }
  }

  // Schedule a timer completion reminder (for TimerScreen integration)
  Future<void> scheduleTimerReminder(int seconds, String title) async {
    try {
      final deadline = DateTime.now().add(Duration(seconds: seconds));
      final androidDetails = AndroidNotificationDetails(
        'timer_channel',
        'Timer Reminders',
        channelDescription: 'Notifications for timer completion',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('timer_complete_sound'),
      );
      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      final platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        title.hashCode,
        'Timer Completed: $title',
        'Your timer has finished!',
        tz.TZDateTime.from(deadline, tz.local),
        platformDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Error scheduling timer reminder: $e');
    }
  }
}