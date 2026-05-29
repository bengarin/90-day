import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'constants.dart';

/// Thin wrapper around flutter_local_notifications.
/// Schedules a single daily reminder at a chosen hour/minute.
class Notifications {
  static final Notifications instance = Notifications._();
  Notifications._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));
    _ready = true;
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Schedule a single daily reminder at [hour]:[minute].
  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required int streak,
  }) async {
    await init();
    await cancelAll();

    final body = _messageForStreak(streak);
    final whenTz = _nextInstance(hour, minute);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_reminder',
        'تذكير يومي',
        channelDescription: 'تذكير اليوم للممارسة',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      ),
    );

    await _plugin.zonedSchedule(
      1001,
      'رفيقي في الإنجليزية',
      body,
      whenTz,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstance(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  String _messageForStreak(int streak) {
    // Find closest key <= streak.
    final keys = AppConstants.motivationByStreak.keys.toList()..sort();
    var chosen = AppConstants.motivationByStreak[0]!;
    for (final k in keys) {
      if (streak >= k) chosen = AppConstants.motivationByStreak[k]!;
    }
    return chosen;
  }
}
