import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/notification_service.dart';
import '../models/notification_config.dart';

class NotificationConfigNotifier extends StateNotifier<NotificationConfig> {
  NotificationConfigNotifier() : super(const NotificationConfig()) {
    _load();
  }

  static const _key = 'notification_config_v2';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        state = NotificationConfig.fromJson(
            jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        state = const NotificationConfig();
      }
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.toJson()));
    NotificationService.instance.rescheduleAll(state);
  }

  Future<void> updateFeedingConfig({
    bool? enabled,
    FeedingReminderMode? mode,
    int? intervalMinutes,
    List<TimeOfDayConfig>? fixedTimes,
    bool? vibrate,
    NotificationSound? sound,
  }) async {
    state = state.copyWith(
      feedingEnabled: enabled ?? state.feedingEnabled,
      feedingMode: mode ?? state.feedingMode,
      feedingIntervalMinutes:
          intervalMinutes ?? state.feedingIntervalMinutes,
      feedingFixedTimes: fixedTimes ?? state.feedingFixedTimes,
      feedingVibrate: vibrate ?? state.feedingVibrate,
      feedingSound: sound ?? state.feedingSound,
    );
    await _save();
  }

  Future<void> updatePumpConfig({
    bool? enabled,
    PumpReminderMode? mode,
    int? intervalMinutes,
    List<TimeOfDayConfig>? fixedTimes,
    int? activeHourStart,
    int? activeHourEnd,
    int? dailyGoalSessions,
    bool? showProgress,
  }) async {
    state = state.copyWith(
      pumpEnabled: enabled ?? state.pumpEnabled,
      pumpMode: mode ?? state.pumpMode,
      pumpIntervalMinutes: intervalMinutes ?? state.pumpIntervalMinutes,
      pumpFixedTimes: fixedTimes ?? state.pumpFixedTimes,
      pumpActiveHourStart: activeHourStart ?? state.pumpActiveHourStart,
      pumpActiveHourEnd: activeHourEnd ?? state.pumpActiveHourEnd,
      pumpDailyGoalSessions:
          dailyGoalSessions ?? state.pumpDailyGoalSessions,
      pumpShowProgress: showProgress ?? state.pumpShowProgress,
    );
    await _save();
  }

  Future<void> updateSleepConfig({
    bool? enabled,
    bool? windowReminder,
    bool? overtimeAlert,
    int? maxNapMinutes,
  }) async {
    state = state.copyWith(
      sleepEnabled: enabled ?? state.sleepEnabled,
      sleepWindowReminder: windowReminder ?? state.sleepWindowReminder,
      sleepOvertimeAlert: overtimeAlert ?? state.sleepOvertimeAlert,
      sleepMaxNapMinutes: maxNapMinutes ?? state.sleepMaxNapMinutes,
    );
    await _save();
  }

  Future<void> updateVaccineConfig({
    bool? enabled,
    int? daysBeforeAlert,
    bool? secondAlert,
    bool? overdueAlert,
  }) async {
    state = state.copyWith(
      vaccineEnabled: enabled ?? state.vaccineEnabled,
      vaccineDaysBeforeAlert:
          daysBeforeAlert ?? state.vaccineDaysBeforeAlert,
      vaccineSecondAlert: secondAlert ?? state.vaccineSecondAlert,
      vaccineOverdueAlert: overdueAlert ?? state.vaccineOverdueAlert,
    );
    await _save();
  }

  Future<void> updateMilkStashConfig({
    bool? enabled,
    int? expiryDays,
    bool? lowAlert,
    int? lowThresholdMl,
  }) async {
    state = state.copyWith(
      milkStashEnabled: enabled ?? state.milkStashEnabled,
      milkStashExpiryDays: expiryDays ?? state.milkStashExpiryDays,
      milkStashLowAlert: lowAlert ?? state.milkStashLowAlert,
      milkStashLowThresholdMl:
          lowThresholdMl ?? state.milkStashLowThresholdMl,
    );
    await _save();
  }

  Future<void> updateQuietHours({
    bool? enabled,
    int? start,
    int? end,
    bool? exceptVaccine,
  }) async {
    state = state.copyWith(
      quietHoursEnabled: enabled ?? state.quietHoursEnabled,
      quietHourStart: start ?? state.quietHourStart,
      quietHourEnd: end ?? state.quietHourEnd,
      quietHoursExceptVaccine:
          exceptVaccine ?? state.quietHoursExceptVaccine,
    );
    await _save();
  }

  Future<void> updateWeeklyReport({
    bool? enabled,
    int? dayOfWeek,
    int? hour,
  }) async {
    state = state.copyWith(
      weeklyReportEnabled: enabled ?? state.weeklyReportEnabled,
      weeklyReportDayOfWeek: dayOfWeek ?? state.weeklyReportDayOfWeek,
      weeklyReportHour: hour ?? state.weeklyReportHour,
    );
    await _save();
  }

  Future<void> applyPreset(NotificationPreset preset) async {
    switch (preset) {
      case NotificationPreset.newborn:
        state = state.copyWith(
          feedingIntervalMinutes: 120,
          pumpIntervalMinutes: 180,
          quietHourStart: 21,
          quietHourEnd: 7,
        );
      case NotificationPreset.months3to6:
        state = state.copyWith(
          feedingIntervalMinutes: 180,
          pumpIntervalMinutes: 240,
          quietHourStart: 22,
          quietHourEnd: 6,
        );
      case NotificationPreset.months6plus:
        state = state.copyWith(
          feedingIntervalMinutes: 240,
          pumpMode: PumpReminderMode.fixed,
          pumpFixedTimes: const [
            TimeOfDayConfig(hour: 7, minute: 0, label: 'Sáng'),
            TimeOfDayConfig(hour: 13, minute: 0, label: 'Trưa'),
          ],
          quietHourStart: 22,
          quietHourEnd: 6,
        );
      case NotificationPreset.custom:
        break;
    }
    await _save();
  }

  Future<void> resetToDefault() async {
    state = const NotificationConfig();
    await _save();
  }
}

enum NotificationPreset { newborn, months3to6, months6plus, custom }

final notificationConfigProvider =
    StateNotifierProvider<NotificationConfigNotifier, NotificationConfig>(
  (ref) => NotificationConfigNotifier(),
);
