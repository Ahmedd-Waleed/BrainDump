/// Notification Service
///
/// Handles local notifications for daily review reminders,
/// deadline alerts, and weekly insights.

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance =
      NotificationService._privateConstructor();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ═══════════════════════════════════════
  //  INIT
  // ═══════════════════════════════════════

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);

    // Request permission on Android 13+
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    _initialized = true;
  }

  // ═══════════════════════════════════════
  //  SHOW INSTANT NOTIFICATION
  // ═══════════════════════════════════════

  Future<void> showCaptureSavedNotification(String content) async {
    await _plugin.show(
      0,
      '✨ Thought Captured',
      content.length > 80 ? '${content.substring(0, 80)}...' : content,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'capture_channel',
          'Captures',
          channelDescription: 'Notifications when thoughts are captured',
          importance: Importance.low,
          priority: Priority.low,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // ═══════════════════════════════════════
  //  SCHEDULE DAILY REVIEW
  // ═══════════════════════════════════════

  Future<void> scheduleDailyReview({int hour = 20, int minute = 0}) async {
    if (!_initialized) await init();

    try {
      await _plugin.zonedSchedule(
        100,
        '🧠 Time to review your thoughts',
        'You have unreviewed captures waiting for you.',
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_review_channel',
            'Daily Review',
            channelDescription: 'Daily reminder to review your captures',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Failed to schedule daily review: $e');
    }
  }

  Future<void> cancelDailyReview() async {
    await _plugin.cancel(100);
  }

  // ═══════════════════════════════════════
  //  DEADLINE ALERTS
  // ═══════════════════════════════════════

  Future<void> scheduleDeadlineAlert({
    required String taskId,
    required String taskTitle,
    required DateTime deadline,
  }) async {
    if (!_initialized) await init();

    // Schedule for 1 day before deadline at 9 AM
    final alertTime = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
      9,
      0,
    ).subtract(const Duration(days: 1));

    if (alertTime.isBefore(DateTime.now())) return;

    try {
      await _plugin.zonedSchedule(
        taskId.hashCode,
        '⏰ Deadline tomorrow',
        taskTitle,
        tz.TZDateTime.from(alertTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'deadline_channel',
            'Deadline Alerts',
            channelDescription: 'Reminders for upcoming deadlines',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Failed to schedule deadline alert: $e');
    }
  }

  // ═══════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
