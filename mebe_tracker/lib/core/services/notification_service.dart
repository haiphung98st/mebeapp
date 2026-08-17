import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../shared/models/notification_config.dart';

const _blossom = Color(0xFFF472A0);

// ── Notification ID ranges ─────────────────────────────────
// 1001           feeding next-cue (one-shot)
// 2000–2019      pump fixed-time daily slots
// 2100–2123      pump interval daily slots
// 2200           pump progress check (21h)
// 3001           weekly report
// 4000–4099      vaccine upcoming (index-based)
// 4100–4199      vaccine day-before (index-based)
// 5001           milk stash expiring
// 5002           milk stash low

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  GoRouter? _router;

  void attachRouter(GoRouter router) => _router = router;

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload == 'weekly_report') {
      _router?.go('/home/stats');
    } else if (response.payload == 'vaccine') {
      _router?.go('/vaccine');
    }
  }

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(
          android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    _initialized = true;
  }

  Future<void> requestPermission() async {
    if (!_initialized) await init();
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  // ── CORE HELPER ─────────────────────────────────────────

  NotificationDetails _details(
    String channelId,
    String channelName, {
    bool vibrate = true,
    String? sound,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        color: _blossom,
        enableVibration: vibrate,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  bool _isQuietHour(DateTime time, NotificationConfig config,
      {bool isVaccine = false}) {
    if (!config.quietHoursEnabled) return false;
    if (isVaccine && config.quietHoursExceptVaccine) return false;
    final h = time.hour;
    final start = config.quietHourStart;
    final end = config.quietHourEnd;
    return start > end
        ? h >= start || h < end
        : h >= start && h < end;
  }

  // ── RESCHEDULE ALL ───────────────────────────────────────

  Future<void> rescheduleAll(NotificationConfig config) async {
    if (!_initialized) await init();
    // Cancel pump and progress slots
    for (var i = 2000; i <= 2019; i++) {
      await _plugin.cancel(i);
    }
    for (var i = 2100; i <= 2123; i++) {
      await _plugin.cancel(i);
    }
    await _plugin.cancel(2200);

    if (config.pumpEnabled) {
      await schedulePumpReminders(config);
    }
    if (config.weeklyReportEnabled) {
      // Weekly report is rescheduled via weeklyReportSchedulerProvider
      // (needs baby name), so we only cancel here if disabled.
    } else {
      await _plugin.cancel(3001);
    }
  }

  // ── FEEDING ──────────────────────────────────────────────

  Future<void> scheduleFeedingReminder(
      NotificationConfig config, DateTime lastFeedingTime) async {
    if (!_initialized) await init();
    if (!config.feedingEnabled) {
      await _plugin.cancel(1001);
      return;
    }

    DateTime? nextTime;
    if (config.feedingMode == FeedingReminderMode.auto) {
      nextTime = lastFeedingTime
          .add(Duration(minutes: config.feedingIntervalMinutes));
    } else {
      final now = DateTime.now();
      final enabled = config.feedingFixedTimes
          .where((t) => t.enabled)
          .toList()
        ..sort((a, b) =>
            (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
      for (final t in enabled) {
        final candidate = DateTime(
            now.year, now.month, now.day, t.hour, t.minute);
        if (candidate.isAfter(now)) {
          nextTime = candidate;
          break;
        }
      }
      if (nextTime == null && enabled.isNotEmpty) {
        final t = enabled.first;
        nextTime = DateTime(now.year, now.month, now.day + 1, t.hour, t.minute);
      }
    }

    if (nextTime == null || nextTime.isBefore(DateTime.now())) return;
    if (_isQuietHour(nextTime, config)) return;

    await _plugin.cancel(1001);
    await _plugin.zonedSchedule(
      1001,
      '🐰 Đến giờ cho bé bú rồi!',
      'Khoảng cách cữ bú đã đủ rồi nhé',
      tz.TZDateTime.from(nextTime, tz.local),
      _details('mebe_reminder', 'Nhắc nhở',
          vibrate: config.feedingVibrate),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ── PUMP ─────────────────────────────────────────────────

  Future<void> schedulePumpReminders(NotificationConfig config) async {
    if (!_initialized) await init();
    if (!config.pumpEnabled ||
        config.pumpMode == PumpReminderMode.disabled) {
      return;
    }

    if (config.pumpMode == PumpReminderMode.fixed) {
      var id = 2000;
      for (final t in config.pumpFixedTimes.where((t) => t.enabled)) {
        if (id > 2019) break;
        await _plugin.zonedSchedule(
          id++,
          '🥛 Đến giờ hút sữa!',
          t.label != null ? '${t.label} — hãy hút sữa nhé' : 'Đừng quên hút sữa nhé',
          _nextDailyTime(t.hour, t.minute),
          _details('pump_reminder', 'Hút sữa'),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    } else {
      // Interval mode: schedule daily slots within active hours
      final startH = config.pumpActiveHourStart;
      final endH = config.pumpActiveHourEnd;
      final gapH = config.pumpIntervalMinutes ~/ 60;
      var id = 2100;
      for (var h = startH; h <= endH && id <= 2123; h += gapH.clamp(1, 6)) {
        await _plugin.zonedSchedule(
          id++,
          '🥛 Đến giờ hút sữa!',
          'Hút sữa lúc ${h.toString().padLeft(2, '0')}:00 để đảm bảo nguồn sữa nhé',
          _nextDailyTime(h, 0),
          _details('pump_reminder', 'Hút sữa'),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    }

    if (config.pumpShowProgress) {
      await _plugin.zonedSchedule(
        2200,
        '🥛 Tiến độ hút sữa hôm nay',
        'Kiểm tra xem bạn đã đạt mục tiêu ${config.pumpDailyGoalSessions} phiên chưa',
        _nextDailyTime(21, 0),
        _details('pump_reminder', 'Hút sữa'),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  // ── VACCINE ──────────────────────────────────────────────

  Future<void> scheduleVaccineReminders(
      NotificationConfig config,
      List<({String key, String name, DateTime scheduledDate})>
          upcoming) async {
    if (!_initialized) await init();
    for (var i = 4000; i <= 4199; i++) {
      await _plugin.cancel(i);
    }
    if (!config.vaccineEnabled) return;

    var id = 4000;
    for (final v in upcoming) {
      if (id >= 4100) break;
      final alertDate = v.scheduledDate
          .subtract(Duration(days: config.vaccineDaysBeforeAlert));
      if (alertDate.isAfter(DateTime.now())) {
        await _plugin.zonedSchedule(
          id++,
          '💉 Sắp đến lịch tiêm của bé',
          'Còn ${config.vaccineDaysBeforeAlert} ngày nữa tiêm ${v.name}',
          tz.TZDateTime.from(
              DateTime(alertDate.year, alertDate.month, alertDate.day, 9),
              tz.local),
          _details('vaccine_alert', 'Tiêm chủng'),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'vaccine',
        );
      }

      if (config.vaccineSecondAlert) {
        final dayBefore = v.scheduledDate.subtract(const Duration(days: 1));
        if (dayBefore.isAfter(DateTime.now())) {
          var secondId = id + 100;
          if (secondId < 4200) {
            await _plugin.zonedSchedule(
              secondId,
              '💉 Ngày mai tiêm ${v.name}',
              'Nhớ đưa bé đi tiêm đúng lịch nhé',
              tz.TZDateTime.from(
                  DateTime(dayBefore.year, dayBefore.month, dayBefore.day, 9),
                  tz.local),
              _details('vaccine_alert', 'Tiêm chủng'),
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              payload: 'vaccine',
            );
          }
        }
      }

      if (config.vaccineOverdueAlert &&
          v.scheduledDate.isBefore(DateTime.now())) {
        await showImmediateNotification(
          id,
          '⚠️ Bé chưa tiêm ${v.name}',
          'Đã quá hạn tiêm — hãy đặt lịch sớm nhé',
          payload: 'vaccine',
        );
        id++;
      }
    }
  }

  // ── MILK STASH ───────────────────────────────────────────

  Future<void> scheduleMilkStashAlerts(
      NotificationConfig config, double totalFreshMl,
      {List<({double amountMl, DateTime expiresAt})> expiring =
          const []}) async {
    if (!_initialized) await init();
    await _plugin.cancel(5001);
    await _plugin.cancel(5002);
    if (!config.milkStashEnabled) return;

    for (final item in expiring) {
      final daysLeft =
          item.expiresAt.difference(DateTime.now()).inDays;
      if (daysLeft <= config.milkStashExpiryDays) {
        await showImmediateNotification(
          5001,
          '🐰 Sữa sắp hết hạn',
          '${item.amountMl.toStringAsFixed(0)}ml sữa sẽ hết hạn trong $daysLeft ngày',
        );
        break;
      }
    }

    if (config.milkStashLowAlert &&
        totalFreshMl < config.milkStashLowThresholdMl) {
      await showImmediateNotification(
        5002,
        '🧊 Kho sữa sắp hết',
        'Chỉ còn ${totalFreshMl.toStringAsFixed(0)}ml — cần hút thêm sữa',
      );
    }
  }

  // ── WONDER WEEKS ─────────────────────────────────────────
  // IDs 6000–6099 (3 per leap: pre-storm, storm-start, storm-end)

  Future<void> scheduleWonderWeeksAlerts({
    required DateTime dateOfBirth,
    required DateTime? edd,
    required List<({int number, String name, int stormStartWeek, int stormEndWeek})> leaps,
  }) async {
    if (!_initialized) await init();
    for (var i = 6000; i <= 6099; i++) {
      await _plugin.cancel(i);
    }

    final base = edd?.subtract(const Duration(days: 280)) ?? dateOfBirth;

    for (final leap in leaps) {
      final stormStart = base.add(Duration(days: leap.stormStartWeek * 7));
      final stormEnd = base.add(Duration(days: leap.stormEndWeek * 7));
      final preStorm = stormStart.subtract(const Duration(days: 3));
      final now = DateTime.now();

      final baseId = 6000 + leap.number * 3;

      if (preStorm.isAfter(now)) {
        await _plugin.zonedSchedule(
          baseId,
          '🌪️ Giai đoạn khủng hoảng ${leap.name} sắp bắt đầu',
          'Còn 3 ngày nữa đến Wonder Week #${leap.number}. Hãy chuẩn bị nhé!',
          tz.TZDateTime.from(
              DateTime(preStorm.year, preStorm.month, preStorm.day, 9), tz.local),
          _details('wonder_weeks', 'Wonder Weeks'),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'wonder_weeks',
        );
      }
      if (stormStart.isAfter(now)) {
        await _plugin.zonedSchedule(
          baseId + 1,
          '🌪️ Leap ${leap.number}: ${leap.name} bắt đầu',
          'Bé có thể quấy và khó ngủ hơn trong ${leap.stormEndWeek - leap.stormStartWeek} tuần tới',
          tz.TZDateTime.from(
              DateTime(stormStart.year, stormStart.month, stormStart.day, 9), tz.local),
          _details('wonder_weeks', 'Wonder Weeks'),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'wonder_weeks',
        );
      }
      if (stormEnd.isAfter(now)) {
        await _plugin.zonedSchedule(
          baseId + 2,
          '☀️ Leap ${leap.number} qua rồi!',
          'Bé đã vượt qua Wonder Week #${leap.number} — giai đoạn tươi sáng bắt đầu!',
          tz.TZDateTime.from(
              DateTime(stormEnd.year, stormEnd.month, stormEnd.day, 9), tz.local),
          _details('wonder_weeks', 'Wonder Weeks'),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'wonder_weeks',
        );
      }
    }
  }

  // ── ANNIVERSARY ───────────────────────────────────────────
  // ID 7000: next monthly milestone, 7001: yearly birthday

  Future<void> scheduleAnniversaryReminders({
    required String babyName,
    required DateTime dateOfBirth,
  }) async {
    if (!_initialized) await init();
    await _plugin.cancel(7000);
    await _plugin.cancel(7001);

    final now = DateTime.now();

    // Next monthly milestone
    final months = now.difference(dateOfBirth).inDays ~/ 30 + 1;
    final nextMonthly = DateTime(
        dateOfBirth.year + (dateOfBirth.month + months - 1) ~/ 12,
        (dateOfBirth.month + months - 1) % 12 + 1,
        dateOfBirth.day,
        9);
    if (nextMonthly.isAfter(now) && months < 24) {
      await _plugin.zonedSchedule(
        7000,
        '🎂 $babyName tròn $months tháng tuổi rồi!',
        'Chúc mừng cột mốc quan trọng của bé nhé!',
        tz.TZDateTime.from(nextMonthly, tz.local),
        _details('anniversary', 'Kỷ niệm'),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    // First birthday
    final firstBirthday = DateTime(dateOfBirth.year + 1, dateOfBirth.month,
        dateOfBirth.day, 9);
    if (firstBirthday.isAfter(now)) {
      await _plugin.zonedSchedule(
        7001,
        '🎉 $babyName tròn 1 tuổi!',
        'Một năm tuyệt vời đã qua — Chúc mừng sinh nhật bé yêu!',
        tz.TZDateTime.from(firstBirthday, tz.local),
        _details('anniversary', 'Kỷ niệm'),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // ── LEGACY / CONVENIENCE ─────────────────────────────────

  Future<void> showImmediateNotification(int id, String title, String body,
      {String? payload}) async {
    if (!_initialized) await init();
    await _plugin.show(
      id,
      title,
      body,
      _details('mebe_reminder', 'Nhắc nhở'),
      payload: payload,
    );
  }

  Future<void> scheduleNotification(
      int id, String title, String body, DateTime scheduledDate) async {
    if (!_initialized) await init();
    if (scheduledDate.isBefore(DateTime.now())) return;
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      _details('mebe_reminder', 'Nhắc nhở'),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleWeeklyReport(String babyName,
      {int dayOfWeek = DateTime.sunday, int hour = 9}) async {
    if (!_initialized) await init();
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    while (scheduled.weekday != dayOfWeek || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      3001,
      '🐰 Báo cáo tuần của Bé $babyName đã sẵn sàng!',
      'Xem thống kê 7 ngày qua nhé',
      scheduled,
      _details('weekly_report', 'Báo cáo tuần'),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'weekly_report',
    );
  }

  Future<void> showExpiringMilkNotification(double amountMl) =>
      showImmediateNotification(
        1001,
        '🐰 Sữa sắp hết hạn',
        'Còn ${amountMl.toStringAsFixed(0)}ml sữa sẽ hết hạn trong 24h tới',
      );

  Future<void> showLowDiaperCountNotification() =>
      showImmediateNotification(
        1002,
        '🐰 Bé có vẻ ít thay tã hôm nay',
        'Hôm nay bé chưa thay tã đủ 3 lần. Kiểm tra bé nhé!',
      );

  Future<void> showUpcomingVaccineNotification(String vaccineName) =>
      showImmediateNotification(
        1003,
        '🐰 Bé sắp đến lịch tiêm',
        'Sắp đến lịch tiêm $vaccineName cho bé',
        payload: 'vaccine',
      );

  Future<void> schedulePumpReminder(int intervalHours) async {
    if (!_initialized) await init();
    await _plugin.periodicallyShowWithDuration(
      2003,
      '🥛 Đến giờ hút sữa rồi!',
      'Đã $intervalHours giờ kể từ lần hút sữa trước',
      Duration(hours: intervalHours),
      _details('pump_reminder', 'Hút sữa'),
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

  // ── HELPER ───────────────────────────────────────────────

  tz.TZDateTime _nextDailyTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
