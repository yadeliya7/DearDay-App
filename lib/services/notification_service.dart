import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Helper: Extracts "Europe/London" from messy emulator strings like "TimezoneInfo(Europe/London...)"
  String _cleanTimezone(String rawTimezone) {
    if (!rawTimezone.contains("TimezoneInfo")) {
      return rawTimezone;
    }
    // Regex to find "Continent/City" pattern
    final RegExp regex = RegExp(r'([A-Za-z]+/[A-Za-z_]+)');
    final Match? match = regex.firstMatch(rawTimezone);
    if (match != null) {
      return match.group(0)!;
    }
    return 'UTC'; // Safe fallback
  }

  Future<void> init() async {
    tz.initializeTimeZones();

    try {
      final rawTimezone = await FlutterTimezone.getLocalTimezone();
      final String cleanZone = _cleanTimezone(rawTimezone.toString());
      tz.setLocalLocation(tz.getLocation(cleanZone));
      debugPrint("✅ Timezone initialized: $cleanZone");
    } catch (e) {
      debugPrint("⚠️ Timezone error ($e). Fallback to UTC.");
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/app_icon');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle tap
      },
    );

    await requestPermissions();
  }

  Future<void> requestPermissions() async {
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // ⚡ CRITICAL: Explicitly create notification channels
    await _createNotificationChannels();
  }

  /// Explicitly create all notification channels
  Future<void> _createNotificationChannels() async {
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation == null) return;

    // Daily Reminder Channel
    const AndroidNotificationChannel dailyChannel = AndroidNotificationChannel(
      'daily_reminder',
      'Daily Reminders',
      description: 'Daily reminder to journal',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    // Test Scheduled Channel
    const AndroidNotificationChannel testChannel = AndroidNotificationChannel(
      'test_scheduled_channel',
      'Scheduled Test Notifications',
      description: 'Test channel for scheduled notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    // Trial Reminder Channel
    const AndroidNotificationChannel trialChannel = AndroidNotificationChannel(
      'trial_reminder',
      'Trial Reminders',
      description: 'Reminder for subscription trial ending',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await androidImplementation.createNotificationChannel(dailyChannel);
    await androidImplementation.createNotificationChannel(testChannel);
    await androidImplementation.createNotificationChannel(trialChannel);

    debugPrint('✅ Notification channels created successfully');
  }

  Future<void> scheduleDailyReminder(
    TimeOfDay time,
    String title,
    String body,
  ) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    debugPrint('🕒 Scheduling Daily Reminder...');
    debugPrint('📍 Local Timezone: ${tz.local.name}');
    debugPrint('⌚ Current Time (Local): $now');
    debugPrint('🎯 Target Time (Hour: ${time.hour}, Minute: ${time.minute})');

    if (scheduledDate.isBefore(now)) {
      debugPrint('⚠️ Target time passed for today, scheduling for tomorrow.');
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    debugPrint('✅ Final Scheduled Date (Local): $scheduledDate');

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminders',
          channelDescription: 'Daily reminder to journal',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleTrialEndingReminder(String title, String body) async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = now.add(const Duration(days: 5));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'trial_reminder',
          'Trial Reminders',
          channelDescription: 'Reminder for subscription trial ending',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelDailyReminder() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'test_channel_global',
          'Test Notifications',
          channelDescription: 'System test notifications',
          importance: Importance.max,
          priority: Priority.high,
        );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      888,
      'System Check ✓',
      'Timezone: ${tz.local.name}',
      details,
    );
  }

  /// TEST: Schedule a notification 1 minute from now
  Future<void> scheduleTestReminderIn1Minute() async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = now.add(const Duration(minutes: 1));

    debugPrint('🧪 TEST: Scheduling notification for 1 minute from now...');
    debugPrint('📍 Current Time: $now');
    debugPrint('🎯 Scheduled Time: $scheduledDate');

    await flutterLocalNotificationsPlugin.zonedSchedule(
      999, // Different ID for test
      '🧪 Test Hatırlatıcı',
      'Bu bildirim 1 dakika önce ayarlandı. Eğer bunu görüyorsan, zamanlanmış bildirimler çalışıyor! ✅',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_scheduled_channel',
          'Scheduled Test Notifications',
          channelDescription: 'Test channel for scheduled notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint('✅ Test notification scheduled successfully!');
  }

  /// TEST: Schedule a notification 10 SECONDS from now (FAST TEST)
  Future<void> scheduleTestIn10Seconds() async {
    debugPrint('⚡ FAST TEST: Starting 10-second notification test...');

    // ⚡ CRITICAL: Ensure channels are created FIRST
    debugPrint('📢 Step 1: Creating notification channels...');
    await createNotificationChannels();

    debugPrint('📢 Step 2: Requesting permissions...');
    await requestPermissions();

    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = now.add(const Duration(seconds: 10));

    debugPrint('📢 Step 3: Scheduling notification...');
    debugPrint('📍 Current Time: $now');
    debugPrint('🎯 Scheduled Time: $scheduledDate');
    debugPrint('🔔 Channel ID: test_scheduled_channel');

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        1000, // Different ID
        '⚡ 10 Saniye Testi',
        'Bu bildirim 10 saniye önce ayarlandı! Şu an: ${DateTime.now().toString().substring(11, 19)}',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_scheduled_channel',
            'Scheduled Test Notifications',
            channelDescription: 'Test channel for scheduled notifications',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('✅ 10-second test scheduled successfully!');
      debugPrint('⏰ Wait 10 seconds and check if notification appears...');
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR scheduling notification: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Public method to create notification channels (can be called explicitly)
  Future<void> createNotificationChannels() async {
    await _createNotificationChannels();
  }
}
