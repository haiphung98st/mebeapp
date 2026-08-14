import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_config.freezed.dart';
part 'notification_config.g.dart';

enum FeedingReminderMode { auto, fixed }

enum PumpReminderMode { interval, fixed, disabled }

// ignore: constant_identifier_names
enum NotificationSound { gentle, default_, cheerful, silent }

@freezed
class TimeOfDayConfig with _$TimeOfDayConfig {
  const factory TimeOfDayConfig({
    required int hour,
    required int minute,
    @Default(true) bool enabled,
    String? label,
  }) = _TimeOfDayConfig;

  factory TimeOfDayConfig.fromJson(Map<String, dynamic> json) =>
      _$TimeOfDayConfigFromJson(json);
}

@freezed
class NotificationConfig with _$NotificationConfig {
  const factory NotificationConfig({
    // ── CỮ BÚ ──
    @Default(true) bool feedingEnabled,
    @Default(FeedingReminderMode.auto) FeedingReminderMode feedingMode,
    @Default(150) int feedingIntervalMinutes,
    @Default([]) List<TimeOfDayConfig> feedingFixedTimes,
    @Default(true) bool feedingVibrate,
    @Default(NotificationSound.gentle) NotificationSound feedingSound,

    // ── HÚT SỮA ──
    @Default(true) bool pumpEnabled,
    @Default(PumpReminderMode.interval) PumpReminderMode pumpMode,
    @Default(180) int pumpIntervalMinutes,
    @Default([]) List<TimeOfDayConfig> pumpFixedTimes,
    @Default(6) int pumpActiveHourStart,
    @Default(23) int pumpActiveHourEnd,
    @Default(3) int pumpDailyGoalSessions,
    @Default(true) bool pumpShowProgress,

    // ── GIẤC NGỦ ──
    @Default(true) bool sleepEnabled,
    @Default(true) bool sleepWindowReminder,
    @Default(true) bool sleepOvertimeAlert,
    @Default(120) int sleepMaxNapMinutes,

    // ── TIÊM CHỦNG ──
    @Default(true) bool vaccineEnabled,
    @Default(7) int vaccineDaysBeforeAlert,
    @Default(true) bool vaccineSecondAlert,
    @Default(true) bool vaccineOverdueAlert,

    // ── SỮA TỦ ──
    @Default(true) bool milkStashEnabled,
    @Default(2) int milkStashExpiryDays,
    @Default(true) bool milkStashLowAlert,
    @Default(200) int milkStashLowThresholdMl,

    // ── GIỜ YÊN TĨNH ──
    @Default(true) bool quietHoursEnabled,
    @Default(22) int quietHourStart,
    @Default(6) int quietHourEnd,
    @Default(false) bool quietHoursExceptVaccine,

    // ── BÁO CÁO TUẦN ──
    @Default(true) bool weeklyReportEnabled,
    @Default(0) int weeklyReportDayOfWeek,
    @Default(9) int weeklyReportHour,
  }) = _NotificationConfig;

  factory NotificationConfig.fromJson(Map<String, dynamic> json) =>
      _$NotificationConfigFromJson(json);
}
