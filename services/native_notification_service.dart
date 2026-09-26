import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NativeNotificationService {
  NativeNotificationService._();

  static final NativeNotificationService instance =
      NativeNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const AndroidNotificationChannel _channel =
      AndroidNotificationChannel(
    'smritiai_reminders',
    'SmritiAI Reminders',
    description: 'Reminders for tasks, appointments, hydration and care.',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: android,
    );

    await _plugin.initialize(settings);

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(_channel);
    await androidPlugin?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    await initialize();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'smritiai_reminders',
        'SmritiAI Reminders',
        channelDescription:
            'Reminders for tasks, appointments, hydration and care.',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _plugin.show(
      id,
      title,
      body,
      details,
    );
  }

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    await initialize();

    final scheduled = tz.TZDateTime.from(dateTime, tz.local);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'smritiai_reminders',
        'SmritiAI Reminders',
        channelDescription:
            'Reminders for tasks, appointments, hydration and care.',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancel(int id) async {
    await initialize();
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }
}
