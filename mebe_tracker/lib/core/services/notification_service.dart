import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

const _blossom = Color(0xFFF472A0);

/// Thin wrapper around flutter_local_notifications for one-off and scheduled
/// local alerts (feeding/sleep/pump/milk/vaccine reminders). Initialized once
/// from main().
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
    _initialized = true;
  }

  Future<void> requestPermission() async {
    if (!_initialized) await init();
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> showImmediateNotification(int id, String title, String body) async {
    if (!_initialized) await init();
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails('mebe_reminder', 'Nhắc nhở', color: _blossom),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> scheduleNotification(
    int id,
    String title,
    String body,
    DateTime scheduledDate,
  ) async {
    if (!_initialized) await init();
    if (scheduledDate.isBefore(DateTime.now())) return;
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails('mebe_reminder', 'Nhắc nhở', color: _blossom),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> schedulePumpReminder(int intervalHours) async {
    if (!_initialized) await init();
    await _plugin.periodicallyShowWithDuration(
      2003,
      '🥛 Đến giờ hút sữa rồi!',
      'Đã $intervalHours giờ kể từ lần hút sữa trước',
      Duration(hours: intervalHours),
      const NotificationDetails(
        android: AndroidNotificationDetails('pump_reminder', 'Hút sữa', color: _blossom),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelPumpReminder() => cancelNotification(2003);

  Future<void> cancelNotification(int id) async {
    if (!_initialized) await init();
    await _plugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    if (!_initialized) await init();
    await _plugin.cancelAll();
  }

  Future<void> showExpiringMilkNotification(double amountMl) async {
    if (!_initialized) await init();
    await _plugin.show(
      1001,
      '🐰 Sữa sắp hết hạn',
      'Còn ${amountMl.toStringAsFixed(0)}ml sữa sẽ hết hạn trong 24h tới',
      const NotificationDetails(
        android: AndroidNotificationDetails('milk_stash', 'Kho sữa'),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> showLowDiaperCountNotification() async {
    if (!_initialized) await init();
    await _plugin.show(
      1002,
      '🐰 Bé có vẻ ít thay tã hôm nay',
      'Hôm nay bé chưa thay tã đủ 3 lần. Kiểm tra bé nhé!',
      const NotificationDetails(
        android: AndroidNotificationDetails('diaper_alert', 'Thay tã'),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> showUpcomingVaccineNotification(String vaccineName) async {
    if (!_initialized) await init();
    await _plugin.show(
      1003,
      '🐰 Bé sắp đến lịch tiêm',
      'Sắp đến lịch tiêm $vaccineName cho bé',
      const NotificationDetails(
        android: AndroidNotificationDetails('vaccine_alert', 'Tiêm chủng'),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
