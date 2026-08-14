// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TimeOfDayConfigImpl _$$TimeOfDayConfigImplFromJson(
        Map<String, dynamic> json) =>
    _$TimeOfDayConfigImpl(
      hour: (json['hour'] as num).toInt(),
      minute: (json['minute'] as num).toInt(),
      enabled: json['enabled'] as bool? ?? true,
      label: json['label'] as String?,
    );

Map<String, dynamic> _$$TimeOfDayConfigImplToJson(
        _$TimeOfDayConfigImpl instance) =>
    <String, dynamic>{
      'hour': instance.hour,
      'minute': instance.minute,
      'enabled': instance.enabled,
      'label': instance.label,
    };

_$NotificationConfigImpl _$$NotificationConfigImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationConfigImpl(
      feedingEnabled: json['feedingEnabled'] as bool? ?? true,
      feedingMode: $enumDecodeNullable(
              _$FeedingReminderModeEnumMap, json['feedingMode']) ??
          FeedingReminderMode.auto,
      feedingIntervalMinutes:
          (json['feedingIntervalMinutes'] as num?)?.toInt() ?? 150,
      feedingFixedTimes: (json['feedingFixedTimes'] as List<dynamic>?)
              ?.map((e) =>
                  TimeOfDayConfig.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      feedingVibrate: json['feedingVibrate'] as bool? ?? true,
      feedingSound: $enumDecodeNullable(
              _$NotificationSoundEnumMap, json['feedingSound']) ??
          NotificationSound.gentle,
      pumpEnabled: json['pumpEnabled'] as bool? ?? true,
      pumpMode:
          $enumDecodeNullable(_$PumpReminderModeEnumMap, json['pumpMode']) ??
              PumpReminderMode.interval,
      pumpIntervalMinutes:
          (json['pumpIntervalMinutes'] as num?)?.toInt() ?? 180,
      pumpFixedTimes: (json['pumpFixedTimes'] as List<dynamic>?)
              ?.map((e) =>
                  TimeOfDayConfig.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      pumpActiveHourStart:
          (json['pumpActiveHourStart'] as num?)?.toInt() ?? 6,
      pumpActiveHourEnd: (json['pumpActiveHourEnd'] as num?)?.toInt() ?? 23,
      pumpDailyGoalSessions:
          (json['pumpDailyGoalSessions'] as num?)?.toInt() ?? 3,
      pumpShowProgress: json['pumpShowProgress'] as bool? ?? true,
      sleepEnabled: json['sleepEnabled'] as bool? ?? true,
      sleepWindowReminder: json['sleepWindowReminder'] as bool? ?? true,
      sleepOvertimeAlert: json['sleepOvertimeAlert'] as bool? ?? true,
      sleepMaxNapMinutes:
          (json['sleepMaxNapMinutes'] as num?)?.toInt() ?? 120,
      vaccineEnabled: json['vaccineEnabled'] as bool? ?? true,
      vaccineDaysBeforeAlert:
          (json['vaccineDaysBeforeAlert'] as num?)?.toInt() ?? 7,
      vaccineSecondAlert: json['vaccineSecondAlert'] as bool? ?? true,
      vaccineOverdueAlert: json['vaccineOverdueAlert'] as bool? ?? true,
      milkStashEnabled: json['milkStashEnabled'] as bool? ?? true,
      milkStashExpiryDays:
          (json['milkStashExpiryDays'] as num?)?.toInt() ?? 2,
      milkStashLowAlert: json['milkStashLowAlert'] as bool? ?? true,
      milkStashLowThresholdMl:
          (json['milkStashLowThresholdMl'] as num?)?.toInt() ?? 200,
      quietHoursEnabled: json['quietHoursEnabled'] as bool? ?? true,
      quietHourStart: (json['quietHourStart'] as num?)?.toInt() ?? 22,
      quietHourEnd: (json['quietHourEnd'] as num?)?.toInt() ?? 6,
      quietHoursExceptVaccine:
          json['quietHoursExceptVaccine'] as bool? ?? false,
      weeklyReportEnabled: json['weeklyReportEnabled'] as bool? ?? true,
      weeklyReportDayOfWeek:
          (json['weeklyReportDayOfWeek'] as num?)?.toInt() ?? 0,
      weeklyReportHour: (json['weeklyReportHour'] as num?)?.toInt() ?? 9,
    );

Map<String, dynamic> _$$NotificationConfigImplToJson(
        _$NotificationConfigImpl instance) =>
    <String, dynamic>{
      'feedingEnabled': instance.feedingEnabled,
      'feedingMode': _$FeedingReminderModeEnumMap[instance.feedingMode]!,
      'feedingIntervalMinutes': instance.feedingIntervalMinutes,
      'feedingFixedTimes':
          instance.feedingFixedTimes.map((e) => e.toJson()).toList(),
      'feedingVibrate': instance.feedingVibrate,
      'feedingSound': _$NotificationSoundEnumMap[instance.feedingSound]!,
      'pumpEnabled': instance.pumpEnabled,
      'pumpMode': _$PumpReminderModeEnumMap[instance.pumpMode]!,
      'pumpIntervalMinutes': instance.pumpIntervalMinutes,
      'pumpFixedTimes':
          instance.pumpFixedTimes.map((e) => e.toJson()).toList(),
      'pumpActiveHourStart': instance.pumpActiveHourStart,
      'pumpActiveHourEnd': instance.pumpActiveHourEnd,
      'pumpDailyGoalSessions': instance.pumpDailyGoalSessions,
      'pumpShowProgress': instance.pumpShowProgress,
      'sleepEnabled': instance.sleepEnabled,
      'sleepWindowReminder': instance.sleepWindowReminder,
      'sleepOvertimeAlert': instance.sleepOvertimeAlert,
      'sleepMaxNapMinutes': instance.sleepMaxNapMinutes,
      'vaccineEnabled': instance.vaccineEnabled,
      'vaccineDaysBeforeAlert': instance.vaccineDaysBeforeAlert,
      'vaccineSecondAlert': instance.vaccineSecondAlert,
      'vaccineOverdueAlert': instance.vaccineOverdueAlert,
      'milkStashEnabled': instance.milkStashEnabled,
      'milkStashExpiryDays': instance.milkStashExpiryDays,
      'milkStashLowAlert': instance.milkStashLowAlert,
      'milkStashLowThresholdMl': instance.milkStashLowThresholdMl,
      'quietHoursEnabled': instance.quietHoursEnabled,
      'quietHourStart': instance.quietHourStart,
      'quietHourEnd': instance.quietHourEnd,
      'quietHoursExceptVaccine': instance.quietHoursExceptVaccine,
      'weeklyReportEnabled': instance.weeklyReportEnabled,
      'weeklyReportDayOfWeek': instance.weeklyReportDayOfWeek,
      'weeklyReportHour': instance.weeklyReportHour,
    };

const _$FeedingReminderModeEnumMap = {
  FeedingReminderMode.auto: 'auto',
  FeedingReminderMode.fixed: 'fixed',
};

const _$PumpReminderModeEnumMap = {
  PumpReminderMode.interval: 'interval',
  PumpReminderMode.fixed: 'fixed',
  PumpReminderMode.disabled: 'disabled',
};

const _$NotificationSoundEnumMap = {
  NotificationSound.gentle: 'gentle',
  NotificationSound.default_: 'default_',
  NotificationSound.cheerful: 'cheerful',
  NotificationSound.silent: 'silent',
};
