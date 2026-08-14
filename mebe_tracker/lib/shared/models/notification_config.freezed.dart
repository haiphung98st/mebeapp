// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TimeOfDayConfig _$TimeOfDayConfigFromJson(Map<String, dynamic> json) {
  return _TimeOfDayConfig.fromJson(json);
}

/// @nodoc
mixin _$TimeOfDayConfig {
  int get hour => throw _privateConstructorUsedError;
  int get minute => throw _privateConstructorUsedError;
  bool get enabled => throw _privateConstructorUsedError;
  String? get label => throw _privateConstructorUsedError;

  /// Serializes this TimeOfDayConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimeOfDayConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimeOfDayConfigCopyWith<TimeOfDayConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeOfDayConfigCopyWith<$Res> {
  factory $TimeOfDayConfigCopyWith(
          TimeOfDayConfig value, $Res Function(TimeOfDayConfig) then) =
      _$TimeOfDayConfigCopyWithImpl<$Res, TimeOfDayConfig>;
  @useResult
  $Res call({int hour, int minute, bool enabled, String? label});
}

/// @nodoc
class _$TimeOfDayConfigCopyWithImpl<$Res, $Val extends TimeOfDayConfig>
    implements $TimeOfDayConfigCopyWith<$Res> {
  _$TimeOfDayConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimeOfDayConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hour = null,
    Object? minute = null,
    Object? enabled = null,
    Object? label = freezed,
  }) {
    return _then(_value.copyWith(
      hour: null == hour
          ? _value.hour
          : hour // ignore: cast_nullable_to_non_nullable
              as int,
      minute: null == minute
          ? _value.minute
          : minute // ignore: cast_nullable_to_non_nullable
              as int,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      label: freezed == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimeOfDayConfigImplCopyWith<$Res>
    implements $TimeOfDayConfigCopyWith<$Res> {
  factory _$$TimeOfDayConfigImplCopyWith(_$TimeOfDayConfigImpl value,
          $Res Function(_$TimeOfDayConfigImpl) then) =
      __$$TimeOfDayConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int hour, int minute, bool enabled, String? label});
}

/// @nodoc
class __$$TimeOfDayConfigImplCopyWithImpl<$Res>
    extends _$TimeOfDayConfigCopyWithImpl<$Res, _$TimeOfDayConfigImpl>
    implements _$$TimeOfDayConfigImplCopyWith<$Res> {
  __$$TimeOfDayConfigImplCopyWithImpl(_$TimeOfDayConfigImpl _value,
      $Res Function(_$TimeOfDayConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of TimeOfDayConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hour = null,
    Object? minute = null,
    Object? enabled = null,
    Object? label = freezed,
  }) {
    return _then(_$TimeOfDayConfigImpl(
      hour: null == hour
          ? _value.hour
          : hour // ignore: cast_nullable_to_non_nullable
              as int,
      minute: null == minute
          ? _value.minute
          : minute // ignore: cast_nullable_to_non_nullable
              as int,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      label: freezed == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeOfDayConfigImpl extends _TimeOfDayConfig {
  const _$TimeOfDayConfigImpl(
      {required this.hour,
      required this.minute,
      this.enabled = true,
      this.label})
      : super._();

  factory _$TimeOfDayConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeOfDayConfigImplFromJson(json);

  @override
  final int hour;
  @override
  final int minute;
  @override
  @JsonKey()
  final bool enabled;
  @override
  final String? label;

  @override
  String toString() {
    return 'TimeOfDayConfig(hour: $hour, minute: $minute, enabled: $enabled, label: $label)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeOfDayConfigImpl &&
            (identical(other.hour, hour) || other.hour == hour) &&
            (identical(other.minute, minute) || other.minute == minute) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.label, label) || other.label == label));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, hour, minute, enabled, label);

  /// Create a copy of TimeOfDayConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeOfDayConfigImplCopyWith<_$TimeOfDayConfigImpl> get copyWith =>
      __$$TimeOfDayConfigImplCopyWithImpl<_$TimeOfDayConfigImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeOfDayConfigImplToJson(
      this,
    );
  }
}

abstract class _TimeOfDayConfig extends TimeOfDayConfig {
  const factory _TimeOfDayConfig(
      {required final int hour,
      required final int minute,
      final bool enabled,
      final String? label}) = _$TimeOfDayConfigImpl;
  const _TimeOfDayConfig._() : super._();

  factory _TimeOfDayConfig.fromJson(Map<String, dynamic> json) =
      _$TimeOfDayConfigImpl.fromJson;

  @override
  int get hour;
  @override
  int get minute;
  @override
  bool get enabled;
  @override
  String? get label;

  /// Create a copy of TimeOfDayConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeOfDayConfigImplCopyWith<_$TimeOfDayConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationConfig _$NotificationConfigFromJson(Map<String, dynamic> json) {
  return _NotificationConfig.fromJson(json);
}

/// @nodoc
mixin _$NotificationConfig {
  bool get feedingEnabled => throw _privateConstructorUsedError;
  FeedingReminderMode get feedingMode => throw _privateConstructorUsedError;
  int get feedingIntervalMinutes => throw _privateConstructorUsedError;
  List<TimeOfDayConfig> get feedingFixedTimes =>
      throw _privateConstructorUsedError;
  bool get feedingVibrate => throw _privateConstructorUsedError;
  NotificationSound get feedingSound => throw _privateConstructorUsedError;
  bool get pumpEnabled => throw _privateConstructorUsedError;
  PumpReminderMode get pumpMode => throw _privateConstructorUsedError;
  int get pumpIntervalMinutes => throw _privateConstructorUsedError;
  List<TimeOfDayConfig> get pumpFixedTimes =>
      throw _privateConstructorUsedError;
  int get pumpActiveHourStart => throw _privateConstructorUsedError;
  int get pumpActiveHourEnd => throw _privateConstructorUsedError;
  int get pumpDailyGoalSessions => throw _privateConstructorUsedError;
  bool get pumpShowProgress => throw _privateConstructorUsedError;
  bool get sleepEnabled => throw _privateConstructorUsedError;
  bool get sleepWindowReminder => throw _privateConstructorUsedError;
  bool get sleepOvertimeAlert => throw _privateConstructorUsedError;
  int get sleepMaxNapMinutes => throw _privateConstructorUsedError;
  bool get vaccineEnabled => throw _privateConstructorUsedError;
  int get vaccineDaysBeforeAlert => throw _privateConstructorUsedError;
  bool get vaccineSecondAlert => throw _privateConstructorUsedError;
  bool get vaccineOverdueAlert => throw _privateConstructorUsedError;
  bool get milkStashEnabled => throw _privateConstructorUsedError;
  int get milkStashExpiryDays => throw _privateConstructorUsedError;
  bool get milkStashLowAlert => throw _privateConstructorUsedError;
  int get milkStashLowThresholdMl => throw _privateConstructorUsedError;
  bool get quietHoursEnabled => throw _privateConstructorUsedError;
  int get quietHourStart => throw _privateConstructorUsedError;
  int get quietHourEnd => throw _privateConstructorUsedError;
  bool get quietHoursExceptVaccine => throw _privateConstructorUsedError;
  bool get weeklyReportEnabled => throw _privateConstructorUsedError;
  int get weeklyReportDayOfWeek => throw _privateConstructorUsedError;
  int get weeklyReportHour => throw _privateConstructorUsedError;

  /// Serializes this NotificationConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationConfigCopyWith<NotificationConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationConfigCopyWith<$Res> {
  factory $NotificationConfigCopyWith(
          NotificationConfig value, $Res Function(NotificationConfig) then) =
      _$NotificationConfigCopyWithImpl<$Res, NotificationConfig>;
  @useResult
  $Res call({
    bool feedingEnabled,
    FeedingReminderMode feedingMode,
    int feedingIntervalMinutes,
    List<TimeOfDayConfig> feedingFixedTimes,
    bool feedingVibrate,
    NotificationSound feedingSound,
    bool pumpEnabled,
    PumpReminderMode pumpMode,
    int pumpIntervalMinutes,
    List<TimeOfDayConfig> pumpFixedTimes,
    int pumpActiveHourStart,
    int pumpActiveHourEnd,
    int pumpDailyGoalSessions,
    bool pumpShowProgress,
    bool sleepEnabled,
    bool sleepWindowReminder,
    bool sleepOvertimeAlert,
    int sleepMaxNapMinutes,
    bool vaccineEnabled,
    int vaccineDaysBeforeAlert,
    bool vaccineSecondAlert,
    bool vaccineOverdueAlert,
    bool milkStashEnabled,
    int milkStashExpiryDays,
    bool milkStashLowAlert,
    int milkStashLowThresholdMl,
    bool quietHoursEnabled,
    int quietHourStart,
    int quietHourEnd,
    bool quietHoursExceptVaccine,
    bool weeklyReportEnabled,
    int weeklyReportDayOfWeek,
    int weeklyReportHour,
  });
}

/// @nodoc
class _$NotificationConfigCopyWithImpl<$Res, $Val extends NotificationConfig>
    implements $NotificationConfigCopyWith<$Res> {
  _$NotificationConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feedingEnabled = null,
    Object? feedingMode = null,
    Object? feedingIntervalMinutes = null,
    Object? feedingFixedTimes = null,
    Object? feedingVibrate = null,
    Object? feedingSound = null,
    Object? pumpEnabled = null,
    Object? pumpMode = null,
    Object? pumpIntervalMinutes = null,
    Object? pumpFixedTimes = null,
    Object? pumpActiveHourStart = null,
    Object? pumpActiveHourEnd = null,
    Object? pumpDailyGoalSessions = null,
    Object? pumpShowProgress = null,
    Object? sleepEnabled = null,
    Object? sleepWindowReminder = null,
    Object? sleepOvertimeAlert = null,
    Object? sleepMaxNapMinutes = null,
    Object? vaccineEnabled = null,
    Object? vaccineDaysBeforeAlert = null,
    Object? vaccineSecondAlert = null,
    Object? vaccineOverdueAlert = null,
    Object? milkStashEnabled = null,
    Object? milkStashExpiryDays = null,
    Object? milkStashLowAlert = null,
    Object? milkStashLowThresholdMl = null,
    Object? quietHoursEnabled = null,
    Object? quietHourStart = null,
    Object? quietHourEnd = null,
    Object? quietHoursExceptVaccine = null,
    Object? weeklyReportEnabled = null,
    Object? weeklyReportDayOfWeek = null,
    Object? weeklyReportHour = null,
  }) {
    return _then(_value.copyWith(
      feedingEnabled: null == feedingEnabled
          ? _value.feedingEnabled
          : feedingEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      feedingMode: null == feedingMode
          ? _value.feedingMode
          : feedingMode // ignore: cast_nullable_to_non_nullable
              as FeedingReminderMode,
      feedingIntervalMinutes: null == feedingIntervalMinutes
          ? _value.feedingIntervalMinutes
          : feedingIntervalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      feedingFixedTimes: null == feedingFixedTimes
          ? _value.feedingFixedTimes
          : feedingFixedTimes // ignore: cast_nullable_to_non_nullable
              as List<TimeOfDayConfig>,
      feedingVibrate: null == feedingVibrate
          ? _value.feedingVibrate
          : feedingVibrate // ignore: cast_nullable_to_non_nullable
              as bool,
      feedingSound: null == feedingSound
          ? _value.feedingSound
          : feedingSound // ignore: cast_nullable_to_non_nullable
              as NotificationSound,
      pumpEnabled: null == pumpEnabled
          ? _value.pumpEnabled
          : pumpEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      pumpMode: null == pumpMode
          ? _value.pumpMode
          : pumpMode // ignore: cast_nullable_to_non_nullable
              as PumpReminderMode,
      pumpIntervalMinutes: null == pumpIntervalMinutes
          ? _value.pumpIntervalMinutes
          : pumpIntervalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      pumpFixedTimes: null == pumpFixedTimes
          ? _value.pumpFixedTimes
          : pumpFixedTimes // ignore: cast_nullable_to_non_nullable
              as List<TimeOfDayConfig>,
      pumpActiveHourStart: null == pumpActiveHourStart
          ? _value.pumpActiveHourStart
          : pumpActiveHourStart // ignore: cast_nullable_to_non_nullable
              as int,
      pumpActiveHourEnd: null == pumpActiveHourEnd
          ? _value.pumpActiveHourEnd
          : pumpActiveHourEnd // ignore: cast_nullable_to_non_nullable
              as int,
      pumpDailyGoalSessions: null == pumpDailyGoalSessions
          ? _value.pumpDailyGoalSessions
          : pumpDailyGoalSessions // ignore: cast_nullable_to_non_nullable
              as int,
      pumpShowProgress: null == pumpShowProgress
          ? _value.pumpShowProgress
          : pumpShowProgress // ignore: cast_nullable_to_non_nullable
              as bool,
      sleepEnabled: null == sleepEnabled
          ? _value.sleepEnabled
          : sleepEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      sleepWindowReminder: null == sleepWindowReminder
          ? _value.sleepWindowReminder
          : sleepWindowReminder // ignore: cast_nullable_to_non_nullable
              as bool,
      sleepOvertimeAlert: null == sleepOvertimeAlert
          ? _value.sleepOvertimeAlert
          : sleepOvertimeAlert // ignore: cast_nullable_to_non_nullable
              as bool,
      sleepMaxNapMinutes: null == sleepMaxNapMinutes
          ? _value.sleepMaxNapMinutes
          : sleepMaxNapMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      vaccineEnabled: null == vaccineEnabled
          ? _value.vaccineEnabled
          : vaccineEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      vaccineDaysBeforeAlert: null == vaccineDaysBeforeAlert
          ? _value.vaccineDaysBeforeAlert
          : vaccineDaysBeforeAlert // ignore: cast_nullable_to_non_nullable
              as int,
      vaccineSecondAlert: null == vaccineSecondAlert
          ? _value.vaccineSecondAlert
          : vaccineSecondAlert // ignore: cast_nullable_to_non_nullable
              as bool,
      vaccineOverdueAlert: null == vaccineOverdueAlert
          ? _value.vaccineOverdueAlert
          : vaccineOverdueAlert // ignore: cast_nullable_to_non_nullable
              as bool,
      milkStashEnabled: null == milkStashEnabled
          ? _value.milkStashEnabled
          : milkStashEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      milkStashExpiryDays: null == milkStashExpiryDays
          ? _value.milkStashExpiryDays
          : milkStashExpiryDays // ignore: cast_nullable_to_non_nullable
              as int,
      milkStashLowAlert: null == milkStashLowAlert
          ? _value.milkStashLowAlert
          : milkStashLowAlert // ignore: cast_nullable_to_non_nullable
              as bool,
      milkStashLowThresholdMl: null == milkStashLowThresholdMl
          ? _value.milkStashLowThresholdMl
          : milkStashLowThresholdMl // ignore: cast_nullable_to_non_nullable
              as int,
      quietHoursEnabled: null == quietHoursEnabled
          ? _value.quietHoursEnabled
          : quietHoursEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      quietHourStart: null == quietHourStart
          ? _value.quietHourStart
          : quietHourStart // ignore: cast_nullable_to_non_nullable
              as int,
      quietHourEnd: null == quietHourEnd
          ? _value.quietHourEnd
          : quietHourEnd // ignore: cast_nullable_to_non_nullable
              as int,
      quietHoursExceptVaccine: null == quietHoursExceptVaccine
          ? _value.quietHoursExceptVaccine
          : quietHoursExceptVaccine // ignore: cast_nullable_to_non_nullable
              as bool,
      weeklyReportEnabled: null == weeklyReportEnabled
          ? _value.weeklyReportEnabled
          : weeklyReportEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      weeklyReportDayOfWeek: null == weeklyReportDayOfWeek
          ? _value.weeklyReportDayOfWeek
          : weeklyReportDayOfWeek // ignore: cast_nullable_to_non_nullable
              as int,
      weeklyReportHour: null == weeklyReportHour
          ? _value.weeklyReportHour
          : weeklyReportHour // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationConfigImplCopyWith<$Res>
    implements $NotificationConfigCopyWith<$Res> {
  factory _$$NotificationConfigImplCopyWith(_$NotificationConfigImpl value,
          $Res Function(_$NotificationConfigImpl) then) =
      __$$NotificationConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool feedingEnabled,
    FeedingReminderMode feedingMode,
    int feedingIntervalMinutes,
    List<TimeOfDayConfig> feedingFixedTimes,
    bool feedingVibrate,
    NotificationSound feedingSound,
    bool pumpEnabled,
    PumpReminderMode pumpMode,
    int pumpIntervalMinutes,
    List<TimeOfDayConfig> pumpFixedTimes,
    int pumpActiveHourStart,
    int pumpActiveHourEnd,
    int pumpDailyGoalSessions,
    bool pumpShowProgress,
    bool sleepEnabled,
    bool sleepWindowReminder,
    bool sleepOvertimeAlert,
    int sleepMaxNapMinutes,
    bool vaccineEnabled,
    int vaccineDaysBeforeAlert,
    bool vaccineSecondAlert,
    bool vaccineOverdueAlert,
    bool milkStashEnabled,
    int milkStashExpiryDays,
    bool milkStashLowAlert,
    int milkStashLowThresholdMl,
    bool quietHoursEnabled,
    int quietHourStart,
    int quietHourEnd,
    bool quietHoursExceptVaccine,
    bool weeklyReportEnabled,
    int weeklyReportDayOfWeek,
    int weeklyReportHour,
  });
}

/// @nodoc
class __$$NotificationConfigImplCopyWithImpl<$Res>
    extends _$NotificationConfigCopyWithImpl<$Res, _$NotificationConfigImpl>
    implements _$$NotificationConfigImplCopyWith<$Res> {
  __$$NotificationConfigImplCopyWithImpl(_$NotificationConfigImpl _value,
      $Res Function(_$NotificationConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feedingEnabled = null,
    Object? feedingMode = null,
    Object? feedingIntervalMinutes = null,
    Object? feedingFixedTimes = null,
    Object? feedingVibrate = null,
    Object? feedingSound = null,
    Object? pumpEnabled = null,
    Object? pumpMode = null,
    Object? pumpIntervalMinutes = null,
    Object? pumpFixedTimes = null,
    Object? pumpActiveHourStart = null,
    Object? pumpActiveHourEnd = null,
    Object? pumpDailyGoalSessions = null,
    Object? pumpShowProgress = null,
    Object? sleepEnabled = null,
    Object? sleepWindowReminder = null,
    Object? sleepOvertimeAlert = null,
    Object? sleepMaxNapMinutes = null,
    Object? vaccineEnabled = null,
    Object? vaccineDaysBeforeAlert = null,
    Object? vaccineSecondAlert = null,
    Object? vaccineOverdueAlert = null,
    Object? milkStashEnabled = null,
    Object? milkStashExpiryDays = null,
    Object? milkStashLowAlert = null,
    Object? milkStashLowThresholdMl = null,
    Object? quietHoursEnabled = null,
    Object? quietHourStart = null,
    Object? quietHourEnd = null,
    Object? quietHoursExceptVaccine = null,
    Object? weeklyReportEnabled = null,
    Object? weeklyReportDayOfWeek = null,
    Object? weeklyReportHour = null,
  }) {
    return _then(_$NotificationConfigImpl(
      feedingEnabled: null == feedingEnabled
          ? _value.feedingEnabled
          : feedingEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      feedingMode: null == feedingMode
          ? _value.feedingMode
          : feedingMode // ignore: cast_nullable_to_non_nullable
              as FeedingReminderMode,
      feedingIntervalMinutes: null == feedingIntervalMinutes
          ? _value.feedingIntervalMinutes
          : feedingIntervalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      feedingFixedTimes: null == feedingFixedTimes
          ? _value._feedingFixedTimes
          : feedingFixedTimes // ignore: cast_nullable_to_non_nullable
              as List<TimeOfDayConfig>,
      feedingVibrate: null == feedingVibrate
          ? _value.feedingVibrate
          : feedingVibrate // ignore: cast_nullable_to_non_nullable
              as bool,
      feedingSound: null == feedingSound
          ? _value.feedingSound
          : feedingSound // ignore: cast_nullable_to_non_nullable
              as NotificationSound,
      pumpEnabled: null == pumpEnabled
          ? _value.pumpEnabled
          : pumpEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      pumpMode: null == pumpMode
          ? _value.pumpMode
          : pumpMode // ignore: cast_nullable_to_non_nullable
              as PumpReminderMode,
      pumpIntervalMinutes: null == pumpIntervalMinutes
          ? _value.pumpIntervalMinutes
          : pumpIntervalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      pumpFixedTimes: null == pumpFixedTimes
          ? _value._pumpFixedTimes
          : pumpFixedTimes // ignore: cast_nullable_to_non_nullable
              as List<TimeOfDayConfig>,
      pumpActiveHourStart: null == pumpActiveHourStart
          ? _value.pumpActiveHourStart
          : pumpActiveHourStart // ignore: cast_nullable_to_non_nullable
              as int,
      pumpActiveHourEnd: null == pumpActiveHourEnd
          ? _value.pumpActiveHourEnd
          : pumpActiveHourEnd // ignore: cast_nullable_to_non_nullable
              as int,
      pumpDailyGoalSessions: null == pumpDailyGoalSessions
          ? _value.pumpDailyGoalSessions
          : pumpDailyGoalSessions // ignore: cast_nullable_to_non_nullable
              as int,
      pumpShowProgress: null == pumpShowProgress
          ? _value.pumpShowProgress
          : pumpShowProgress // ignore: cast_nullable_to_non_nullable
              as bool,
      sleepEnabled: null == sleepEnabled
          ? _value.sleepEnabled
          : sleepEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      sleepWindowReminder: null == sleepWindowReminder
          ? _value.sleepWindowReminder
          : sleepWindowReminder // ignore: cast_nullable_to_non_nullable
              as bool,
      sleepOvertimeAlert: null == sleepOvertimeAlert
          ? _value.sleepOvertimeAlert
          : sleepOvertimeAlert // ignore: cast_nullable_to_non_nullable
              as bool,
      sleepMaxNapMinutes: null == sleepMaxNapMinutes
          ? _value.sleepMaxNapMinutes
          : sleepMaxNapMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      vaccineEnabled: null == vaccineEnabled
          ? _value.vaccineEnabled
          : vaccineEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      vaccineDaysBeforeAlert: null == vaccineDaysBeforeAlert
          ? _value.vaccineDaysBeforeAlert
          : vaccineDaysBeforeAlert // ignore: cast_nullable_to_non_nullable
              as int,
      vaccineSecondAlert: null == vaccineSecondAlert
          ? _value.vaccineSecondAlert
          : vaccineSecondAlert // ignore: cast_nullable_to_non_nullable
              as bool,
      vaccineOverdueAlert: null == vaccineOverdueAlert
          ? _value.vaccineOverdueAlert
          : vaccineOverdueAlert // ignore: cast_nullable_to_non_nullable
              as bool,
      milkStashEnabled: null == milkStashEnabled
          ? _value.milkStashEnabled
          : milkStashEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      milkStashExpiryDays: null == milkStashExpiryDays
          ? _value.milkStashExpiryDays
          : milkStashExpiryDays // ignore: cast_nullable_to_non_nullable
              as int,
      milkStashLowAlert: null == milkStashLowAlert
          ? _value.milkStashLowAlert
          : milkStashLowAlert // ignore: cast_nullable_to_non_nullable
              as bool,
      milkStashLowThresholdMl: null == milkStashLowThresholdMl
          ? _value.milkStashLowThresholdMl
          : milkStashLowThresholdMl // ignore: cast_nullable_to_non_nullable
              as int,
      quietHoursEnabled: null == quietHoursEnabled
          ? _value.quietHoursEnabled
          : quietHoursEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      quietHourStart: null == quietHourStart
          ? _value.quietHourStart
          : quietHourStart // ignore: cast_nullable_to_non_nullable
              as int,
      quietHourEnd: null == quietHourEnd
          ? _value.quietHourEnd
          : quietHourEnd // ignore: cast_nullable_to_non_nullable
              as int,
      quietHoursExceptVaccine: null == quietHoursExceptVaccine
          ? _value.quietHoursExceptVaccine
          : quietHoursExceptVaccine // ignore: cast_nullable_to_non_nullable
              as bool,
      weeklyReportEnabled: null == weeklyReportEnabled
          ? _value.weeklyReportEnabled
          : weeklyReportEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      weeklyReportDayOfWeek: null == weeklyReportDayOfWeek
          ? _value.weeklyReportDayOfWeek
          : weeklyReportDayOfWeek // ignore: cast_nullable_to_non_nullable
              as int,
      weeklyReportHour: null == weeklyReportHour
          ? _value.weeklyReportHour
          : weeklyReportHour // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationConfigImpl extends _NotificationConfig {
  const _$NotificationConfigImpl({
    this.feedingEnabled = true,
    this.feedingMode = FeedingReminderMode.auto,
    this.feedingIntervalMinutes = 150,
    final List<TimeOfDayConfig> feedingFixedTimes = const [],
    this.feedingVibrate = true,
    this.feedingSound = NotificationSound.gentle,
    this.pumpEnabled = true,
    this.pumpMode = PumpReminderMode.interval,
    this.pumpIntervalMinutes = 180,
    final List<TimeOfDayConfig> pumpFixedTimes = const [],
    this.pumpActiveHourStart = 6,
    this.pumpActiveHourEnd = 23,
    this.pumpDailyGoalSessions = 3,
    this.pumpShowProgress = true,
    this.sleepEnabled = true,
    this.sleepWindowReminder = true,
    this.sleepOvertimeAlert = true,
    this.sleepMaxNapMinutes = 120,
    this.vaccineEnabled = true,
    this.vaccineDaysBeforeAlert = 7,
    this.vaccineSecondAlert = true,
    this.vaccineOverdueAlert = true,
    this.milkStashEnabled = true,
    this.milkStashExpiryDays = 2,
    this.milkStashLowAlert = true,
    this.milkStashLowThresholdMl = 200,
    this.quietHoursEnabled = true,
    this.quietHourStart = 22,
    this.quietHourEnd = 6,
    this.quietHoursExceptVaccine = false,
    this.weeklyReportEnabled = true,
    this.weeklyReportDayOfWeek = 0,
    this.weeklyReportHour = 9,
  })  : _feedingFixedTimes = feedingFixedTimes,
        _pumpFixedTimes = pumpFixedTimes,
        super._();

  factory _$NotificationConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationConfigImplFromJson(json);

  @override
  @JsonKey()
  final bool feedingEnabled;
  @override
  @JsonKey()
  final FeedingReminderMode feedingMode;
  @override
  @JsonKey()
  final int feedingIntervalMinutes;
  final List<TimeOfDayConfig> _feedingFixedTimes;
  @override
  @JsonKey()
  List<TimeOfDayConfig> get feedingFixedTimes {
    if (_feedingFixedTimes is EqualUnmodifiableListView)
      return _feedingFixedTimes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_feedingFixedTimes);
  }

  @override
  @JsonKey()
  final bool feedingVibrate;
  @override
  @JsonKey()
  final NotificationSound feedingSound;
  @override
  @JsonKey()
  final bool pumpEnabled;
  @override
  @JsonKey()
  final PumpReminderMode pumpMode;
  @override
  @JsonKey()
  final int pumpIntervalMinutes;
  final List<TimeOfDayConfig> _pumpFixedTimes;
  @override
  @JsonKey()
  List<TimeOfDayConfig> get pumpFixedTimes {
    if (_pumpFixedTimes is EqualUnmodifiableListView) return _pumpFixedTimes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pumpFixedTimes);
  }

  @override
  @JsonKey()
  final int pumpActiveHourStart;
  @override
  @JsonKey()
  final int pumpActiveHourEnd;
  @override
  @JsonKey()
  final int pumpDailyGoalSessions;
  @override
  @JsonKey()
  final bool pumpShowProgress;
  @override
  @JsonKey()
  final bool sleepEnabled;
  @override
  @JsonKey()
  final bool sleepWindowReminder;
  @override
  @JsonKey()
  final bool sleepOvertimeAlert;
  @override
  @JsonKey()
  final int sleepMaxNapMinutes;
  @override
  @JsonKey()
  final bool vaccineEnabled;
  @override
  @JsonKey()
  final int vaccineDaysBeforeAlert;
  @override
  @JsonKey()
  final bool vaccineSecondAlert;
  @override
  @JsonKey()
  final bool vaccineOverdueAlert;
  @override
  @JsonKey()
  final bool milkStashEnabled;
  @override
  @JsonKey()
  final int milkStashExpiryDays;
  @override
  @JsonKey()
  final bool milkStashLowAlert;
  @override
  @JsonKey()
  final int milkStashLowThresholdMl;
  @override
  @JsonKey()
  final bool quietHoursEnabled;
  @override
  @JsonKey()
  final int quietHourStart;
  @override
  @JsonKey()
  final int quietHourEnd;
  @override
  @JsonKey()
  final bool quietHoursExceptVaccine;
  @override
  @JsonKey()
  final bool weeklyReportEnabled;
  @override
  @JsonKey()
  final int weeklyReportDayOfWeek;
  @override
  @JsonKey()
  final int weeklyReportHour;

  @override
  String toString() {
    return 'NotificationConfig(feedingEnabled: $feedingEnabled, feedingMode: $feedingMode, feedingIntervalMinutes: $feedingIntervalMinutes, feedingFixedTimes: $feedingFixedTimes, feedingVibrate: $feedingVibrate, feedingSound: $feedingSound, pumpEnabled: $pumpEnabled, pumpMode: $pumpMode, pumpIntervalMinutes: $pumpIntervalMinutes, pumpFixedTimes: $pumpFixedTimes, pumpActiveHourStart: $pumpActiveHourStart, pumpActiveHourEnd: $pumpActiveHourEnd, pumpDailyGoalSessions: $pumpDailyGoalSessions, pumpShowProgress: $pumpShowProgress, sleepEnabled: $sleepEnabled, sleepWindowReminder: $sleepWindowReminder, sleepOvertimeAlert: $sleepOvertimeAlert, sleepMaxNapMinutes: $sleepMaxNapMinutes, vaccineEnabled: $vaccineEnabled, vaccineDaysBeforeAlert: $vaccineDaysBeforeAlert, vaccineSecondAlert: $vaccineSecondAlert, vaccineOverdueAlert: $vaccineOverdueAlert, milkStashEnabled: $milkStashEnabled, milkStashExpiryDays: $milkStashExpiryDays, milkStashLowAlert: $milkStashLowAlert, milkStashLowThresholdMl: $milkStashLowThresholdMl, quietHoursEnabled: $quietHoursEnabled, quietHourStart: $quietHourStart, quietHourEnd: $quietHourEnd, quietHoursExceptVaccine: $quietHoursExceptVaccine, weeklyReportEnabled: $weeklyReportEnabled, weeklyReportDayOfWeek: $weeklyReportDayOfWeek, weeklyReportHour: $weeklyReportHour)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationConfigImpl &&
            (identical(other.feedingEnabled, feedingEnabled) ||
                other.feedingEnabled == feedingEnabled) &&
            (identical(other.feedingMode, feedingMode) ||
                other.feedingMode == feedingMode) &&
            (identical(other.feedingIntervalMinutes, feedingIntervalMinutes) ||
                other.feedingIntervalMinutes == feedingIntervalMinutes) &&
            const DeepCollectionEquality()
                .equals(other._feedingFixedTimes, _feedingFixedTimes) &&
            (identical(other.feedingVibrate, feedingVibrate) ||
                other.feedingVibrate == feedingVibrate) &&
            (identical(other.feedingSound, feedingSound) ||
                other.feedingSound == feedingSound) &&
            (identical(other.pumpEnabled, pumpEnabled) ||
                other.pumpEnabled == pumpEnabled) &&
            (identical(other.pumpMode, pumpMode) ||
                other.pumpMode == pumpMode) &&
            (identical(other.pumpIntervalMinutes, pumpIntervalMinutes) ||
                other.pumpIntervalMinutes == pumpIntervalMinutes) &&
            const DeepCollectionEquality()
                .equals(other._pumpFixedTimes, _pumpFixedTimes) &&
            (identical(other.pumpActiveHourStart, pumpActiveHourStart) ||
                other.pumpActiveHourStart == pumpActiveHourStart) &&
            (identical(other.pumpActiveHourEnd, pumpActiveHourEnd) ||
                other.pumpActiveHourEnd == pumpActiveHourEnd) &&
            (identical(other.pumpDailyGoalSessions, pumpDailyGoalSessions) ||
                other.pumpDailyGoalSessions == pumpDailyGoalSessions) &&
            (identical(other.pumpShowProgress, pumpShowProgress) ||
                other.pumpShowProgress == pumpShowProgress) &&
            (identical(other.sleepEnabled, sleepEnabled) ||
                other.sleepEnabled == sleepEnabled) &&
            (identical(other.sleepWindowReminder, sleepWindowReminder) ||
                other.sleepWindowReminder == sleepWindowReminder) &&
            (identical(other.sleepOvertimeAlert, sleepOvertimeAlert) ||
                other.sleepOvertimeAlert == sleepOvertimeAlert) &&
            (identical(other.sleepMaxNapMinutes, sleepMaxNapMinutes) ||
                other.sleepMaxNapMinutes == sleepMaxNapMinutes) &&
            (identical(other.vaccineEnabled, vaccineEnabled) ||
                other.vaccineEnabled == vaccineEnabled) &&
            (identical(other.vaccineDaysBeforeAlert, vaccineDaysBeforeAlert) ||
                other.vaccineDaysBeforeAlert == vaccineDaysBeforeAlert) &&
            (identical(other.vaccineSecondAlert, vaccineSecondAlert) ||
                other.vaccineSecondAlert == vaccineSecondAlert) &&
            (identical(other.vaccineOverdueAlert, vaccineOverdueAlert) ||
                other.vaccineOverdueAlert == vaccineOverdueAlert) &&
            (identical(other.milkStashEnabled, milkStashEnabled) ||
                other.milkStashEnabled == milkStashEnabled) &&
            (identical(other.milkStashExpiryDays, milkStashExpiryDays) ||
                other.milkStashExpiryDays == milkStashExpiryDays) &&
            (identical(other.milkStashLowAlert, milkStashLowAlert) ||
                other.milkStashLowAlert == milkStashLowAlert) &&
            (identical(
                    other.milkStashLowThresholdMl, milkStashLowThresholdMl) ||
                other.milkStashLowThresholdMl == milkStashLowThresholdMl) &&
            (identical(other.quietHoursEnabled, quietHoursEnabled) ||
                other.quietHoursEnabled == quietHoursEnabled) &&
            (identical(other.quietHourStart, quietHourStart) ||
                other.quietHourStart == quietHourStart) &&
            (identical(other.quietHourEnd, quietHourEnd) ||
                other.quietHourEnd == quietHourEnd) &&
            (identical(
                    other.quietHoursExceptVaccine, quietHoursExceptVaccine) ||
                other.quietHoursExceptVaccine == quietHoursExceptVaccine) &&
            (identical(other.weeklyReportEnabled, weeklyReportEnabled) ||
                other.weeklyReportEnabled == weeklyReportEnabled) &&
            (identical(other.weeklyReportDayOfWeek, weeklyReportDayOfWeek) ||
                other.weeklyReportDayOfWeek == weeklyReportDayOfWeek) &&
            (identical(other.weeklyReportHour, weeklyReportHour) ||
                other.weeklyReportHour == weeklyReportHour));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        feedingEnabled,
        feedingMode,
        feedingIntervalMinutes,
        const DeepCollectionEquality().hash(_feedingFixedTimes),
        feedingVibrate,
        feedingSound,
        pumpEnabled,
        pumpMode,
        pumpIntervalMinutes,
        const DeepCollectionEquality().hash(_pumpFixedTimes),
        pumpActiveHourStart,
        pumpActiveHourEnd,
        pumpDailyGoalSessions,
        pumpShowProgress,
        sleepEnabled,
        sleepWindowReminder,
        sleepOvertimeAlert,
        sleepMaxNapMinutes,
        vaccineEnabled,
        vaccineDaysBeforeAlert,
        vaccineSecondAlert,
        vaccineOverdueAlert,
        milkStashEnabled,
        milkStashExpiryDays,
        milkStashLowAlert,
        milkStashLowThresholdMl,
        quietHoursEnabled,
        quietHourStart,
        quietHourEnd,
        quietHoursExceptVaccine,
        weeklyReportEnabled,
        weeklyReportDayOfWeek,
        weeklyReportHour,
      ]);

  /// Create a copy of NotificationConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationConfigImplCopyWith<_$NotificationConfigImpl> get copyWith =>
      __$$NotificationConfigImplCopyWithImpl<_$NotificationConfigImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationConfigImplToJson(
      this,
    );
  }
}

abstract class _NotificationConfig extends NotificationConfig {
  const factory _NotificationConfig({
    final bool feedingEnabled,
    final FeedingReminderMode feedingMode,
    final int feedingIntervalMinutes,
    final List<TimeOfDayConfig> feedingFixedTimes,
    final bool feedingVibrate,
    final NotificationSound feedingSound,
    final bool pumpEnabled,
    final PumpReminderMode pumpMode,
    final int pumpIntervalMinutes,
    final List<TimeOfDayConfig> pumpFixedTimes,
    final int pumpActiveHourStart,
    final int pumpActiveHourEnd,
    final int pumpDailyGoalSessions,
    final bool pumpShowProgress,
    final bool sleepEnabled,
    final bool sleepWindowReminder,
    final bool sleepOvertimeAlert,
    final int sleepMaxNapMinutes,
    final bool vaccineEnabled,
    final int vaccineDaysBeforeAlert,
    final bool vaccineSecondAlert,
    final bool vaccineOverdueAlert,
    final bool milkStashEnabled,
    final int milkStashExpiryDays,
    final bool milkStashLowAlert,
    final int milkStashLowThresholdMl,
    final bool quietHoursEnabled,
    final int quietHourStart,
    final int quietHourEnd,
    final bool quietHoursExceptVaccine,
    final bool weeklyReportEnabled,
    final int weeklyReportDayOfWeek,
    final int weeklyReportHour,
  }) = _$NotificationConfigImpl;
  const _NotificationConfig._() : super._();

  factory _NotificationConfig.fromJson(Map<String, dynamic> json) =
      _$NotificationConfigImpl.fromJson;

  @override
  bool get feedingEnabled;
  @override
  FeedingReminderMode get feedingMode;
  @override
  int get feedingIntervalMinutes;
  @override
  List<TimeOfDayConfig> get feedingFixedTimes;
  @override
  bool get feedingVibrate;
  @override
  NotificationSound get feedingSound;
  @override
  bool get pumpEnabled;
  @override
  PumpReminderMode get pumpMode;
  @override
  int get pumpIntervalMinutes;
  @override
  List<TimeOfDayConfig> get pumpFixedTimes;
  @override
  int get pumpActiveHourStart;
  @override
  int get pumpActiveHourEnd;
  @override
  int get pumpDailyGoalSessions;
  @override
  bool get pumpShowProgress;
  @override
  bool get sleepEnabled;
  @override
  bool get sleepWindowReminder;
  @override
  bool get sleepOvertimeAlert;
  @override
  int get sleepMaxNapMinutes;
  @override
  bool get vaccineEnabled;
  @override
  int get vaccineDaysBeforeAlert;
  @override
  bool get vaccineSecondAlert;
  @override
  bool get vaccineOverdueAlert;
  @override
  bool get milkStashEnabled;
  @override
  int get milkStashExpiryDays;
  @override
  bool get milkStashLowAlert;
  @override
  int get milkStashLowThresholdMl;
  @override
  bool get quietHoursEnabled;
  @override
  int get quietHourStart;
  @override
  int get quietHourEnd;
  @override
  bool get quietHoursExceptVaccine;
  @override
  bool get weeklyReportEnabled;
  @override
  int get weeklyReportDayOfWeek;
  @override
  int get weeklyReportHour;

  /// Create a copy of NotificationConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationConfigImplCopyWith<_$NotificationConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
