import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettings {
  const NotificationSettings({
    this.feedingReminderEnabled = true,
    this.sleepReminderEnabled = true,
    this.pumpReminderEnabled = false,
    this.pumpIntervalHours = 3,
    this.milkExpiryReminderEnabled = true,
    this.vaccineReminderEnabled = true,
    this.quietHourStart = 23,
    this.quietHourEnd = 5,
  });

  final bool feedingReminderEnabled;
  final bool sleepReminderEnabled;
  final bool pumpReminderEnabled;
  final int pumpIntervalHours;
  final bool milkExpiryReminderEnabled;
  final bool vaccineReminderEnabled;
  final int quietHourStart;
  final int quietHourEnd;

  bool isWithinQuietHours(DateTime time) {
    final hour = time.hour;
    if (quietHourStart <= quietHourEnd) {
      return hour >= quietHourStart && hour < quietHourEnd;
    }
    return hour >= quietHourStart || hour < quietHourEnd;
  }

  NotificationSettings copyWith({
    bool? feedingReminderEnabled,
    bool? sleepReminderEnabled,
    bool? pumpReminderEnabled,
    int? pumpIntervalHours,
    bool? milkExpiryReminderEnabled,
    bool? vaccineReminderEnabled,
    int? quietHourStart,
    int? quietHourEnd,
  }) {
    return NotificationSettings(
      feedingReminderEnabled: feedingReminderEnabled ?? this.feedingReminderEnabled,
      sleepReminderEnabled: sleepReminderEnabled ?? this.sleepReminderEnabled,
      pumpReminderEnabled: pumpReminderEnabled ?? this.pumpReminderEnabled,
      pumpIntervalHours: pumpIntervalHours ?? this.pumpIntervalHours,
      milkExpiryReminderEnabled: milkExpiryReminderEnabled ?? this.milkExpiryReminderEnabled,
      vaccineReminderEnabled: vaccineReminderEnabled ?? this.vaccineReminderEnabled,
      quietHourStart: quietHourStart ?? this.quietHourStart,
      quietHourEnd: quietHourEnd ?? this.quietHourEnd,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier() : super(const NotificationSettings()) {
    _load();
  }

  static const _keyFeeding = 'notif_feeding_enabled';
  static const _keySleep = 'notif_sleep_enabled';
  static const _keyPump = 'notif_pump_enabled';
  static const _keyPumpInterval = 'notif_pump_interval_hours';
  static const _keyMilk = 'notif_milk_enabled';
  static const _keyVaccine = 'notif_vaccine_enabled';
  static const _keyQuietStart = 'notif_quiet_start';
  static const _keyQuietEnd = 'notif_quiet_end';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = NotificationSettings(
      feedingReminderEnabled: prefs.getBool(_keyFeeding) ?? state.feedingReminderEnabled,
      sleepReminderEnabled: prefs.getBool(_keySleep) ?? state.sleepReminderEnabled,
      pumpReminderEnabled: prefs.getBool(_keyPump) ?? state.pumpReminderEnabled,
      pumpIntervalHours: prefs.getInt(_keyPumpInterval) ?? state.pumpIntervalHours,
      milkExpiryReminderEnabled: prefs.getBool(_keyMilk) ?? state.milkExpiryReminderEnabled,
      vaccineReminderEnabled: prefs.getBool(_keyVaccine) ?? state.vaccineReminderEnabled,
      quietHourStart: prefs.getInt(_keyQuietStart) ?? state.quietHourStart,
      quietHourEnd: prefs.getInt(_keyQuietEnd) ?? state.quietHourEnd,
    );
  }

  Future<void> setFeedingReminderEnabled(bool value) async {
    state = state.copyWith(feedingReminderEnabled: value);
    (await SharedPreferences.getInstance()).setBool(_keyFeeding, value);
  }

  Future<void> setSleepReminderEnabled(bool value) async {
    state = state.copyWith(sleepReminderEnabled: value);
    (await SharedPreferences.getInstance()).setBool(_keySleep, value);
  }

  Future<void> setPumpReminderEnabled(bool value) async {
    state = state.copyWith(pumpReminderEnabled: value);
    (await SharedPreferences.getInstance()).setBool(_keyPump, value);
  }

  Future<void> setPumpIntervalHours(int hours) async {
    state = state.copyWith(pumpIntervalHours: hours);
    (await SharedPreferences.getInstance()).setInt(_keyPumpInterval, hours);
  }

  Future<void> setMilkExpiryReminderEnabled(bool value) async {
    state = state.copyWith(milkExpiryReminderEnabled: value);
    (await SharedPreferences.getInstance()).setBool(_keyMilk, value);
  }

  Future<void> setVaccineReminderEnabled(bool value) async {
    state = state.copyWith(vaccineReminderEnabled: value);
    (await SharedPreferences.getInstance()).setBool(_keyVaccine, value);
  }

  Future<void> setQuietHours(int start, int end) async {
    state = state.copyWith(quietHourStart: start, quietHourEnd: end);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyQuietStart, start);
    await prefs.setInt(_keyQuietEnd, end);
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  (ref) => NotificationSettingsNotifier(),
);
