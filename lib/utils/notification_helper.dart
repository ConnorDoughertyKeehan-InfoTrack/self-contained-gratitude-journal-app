// notification_helper.dart
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:self_contained_gratitude/utils/database_helper.dart';
import 'package:self_contained_gratitude/calendar_page/calendar_page.dart';
import 'package:self_contained_gratitude/utils/journal_database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationHelper {
  // 1. Private constructor.
  NotificationHelper._internal();

  // 2. A static, private field holding the single instance.
  static final NotificationHelper _singleton = NotificationHelper._internal();

  // 3. A public static getter to access this same instance.
  static NotificationHelper get instance => _singleton;

  bool hasPermissions = false;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones(); // Initialize the base timezone data
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    final notificationsGranted = await requestNotificationPermissions();
    if(!notificationsGranted){
      return;
    }

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        MaterialPageRoute(builder: (_) => const CalendarPage());
      },
    );

    await _createNotificationChannel();
    await scheduleDailyNotification();
  }

  Future<bool> requestNotificationPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }

      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }

      return await Permission.notification.isGranted &&
          await Permission.scheduleExactAlarm.isGranted;
    }
    else if (Platform.isIOS) {
      final bool granted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      ) ??
          false;

      if(granted){
        return true;
      }
    }

    return false;
  }

  Future<void> _createNotificationChannel() async {
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'daily_gratitude_channel',
        'Daily Gratitude',
        importance: Importance.high,
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  static const String _notificationTimeKey = 'notification_time';
  static const TimeOfDay _defaultTime = TimeOfDay(hour: 12, minute: 0); // Default midday

  Future<void> storeNotificationTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationTimeKey, '${time.hour}:${time.minute}');
  }

  // Retrieve the notification time
  Future<TimeOfDay> getNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_notificationTimeKey);

    if (timeString != null) {
      final parts = timeString.split(':');
      final scheduledTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      return scheduledTime;
    }

    return _defaultTime; // Return midday if no time is stored
  }

  Future<void> scheduleDailyNotification() async {
    final notificationTime = await getNotificationTime();
    final entries = await DatabaseHelper.instance.readAllEntries();
    var gratitudeText = "Remember To Be Grateful";

    if (entries.isNotEmpty) {
      gratitudeText = entries[Random().nextInt(entries.length)].bodyText;
    }

    final nextTime = _getNextScheduledTime(notificationTime);

    const androidDetails = AndroidNotificationDetails(
      'daily_gratitude_channel',
      'Daily Gratitude',
      importance: Importance.high,
      priority: Priority.high,
    );

    const darwinDetails = DarwinNotificationDetails();
    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Gratitude Reminder',
      gratitudeText,
      nextTime,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _getNextScheduledTime(TimeOfDay time) {
    final now = DateTime.now();
    tz.TZDateTime scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (now.isAfter(scheduledTime)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    return scheduledTime;
  }
}