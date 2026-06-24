// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sleep_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SleepEntry _$SleepEntryFromJson(Map<String, dynamic> json) {
  return _SleepEntry.fromJson(json);
}

/// @nodoc
mixin _$SleepEntry {
  String get id => throw _privateConstructorUsedError;
  String get babyId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;
  SleepType get type => throw _privateConstructorUsedError;
  int? get durationMinutes => throw _privateConstructorUsedError;
  SleepQuality? get quality => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this SleepEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SleepEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SleepEntryCopyWith<SleepEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SleepEntryCopyWith<$Res> {
  factory $SleepEntryCopyWith(
          SleepEntry value, $Res Function(SleepEntry) then) =
      _$SleepEntryCopyWithImpl<$Res, SleepEntry>;
  @useResult
  $Res call(
      {String id,
      String babyId,
      String userId,
      DateTime startTime,
      DateTime? endTime,
      SleepType type,
      int? durationMinutes,
      SleepQuality? quality,
      String? notes,
      DateTime createdAt});
}

/// @nodoc
class _$SleepEntryCopyWithImpl<$Res, $Val extends SleepEntry>
    implements $SleepEntryCopyWith<$Res> {
  _$SleepEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SleepEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? babyId = null,
    Object? userId = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? type = null,
    Object? durationMinutes = freezed,
    Object? quality = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      babyId: null == babyId
          ? _value.babyId
          : babyId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SleepType,
      durationMinutes: freezed == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      quality: freezed == quality
          ? _value.quality
          : quality // ignore: cast_nullable_to_non_nullable
              as SleepQuality?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SleepEntryImplCopyWith<$Res>
    implements $SleepEntryCopyWith<$Res> {
  factory _$$SleepEntryImplCopyWith(
          _$SleepEntryImpl value, $Res Function(_$SleepEntryImpl) then) =
      __$$SleepEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String babyId,
      String userId,
      DateTime startTime,
      DateTime? endTime,
      SleepType type,
      int? durationMinutes,
      SleepQuality? quality,
      String? notes,
      DateTime createdAt});
}

/// @nodoc
class __$$SleepEntryImplCopyWithImpl<$Res>
    extends _$SleepEntryCopyWithImpl<$Res, _$SleepEntryImpl>
    implements _$$SleepEntryImplCopyWith<$Res> {
  __$$SleepEntryImplCopyWithImpl(
      _$SleepEntryImpl _value, $Res Function(_$SleepEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of SleepEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? babyId = null,
    Object? userId = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? type = null,
    Object? durationMinutes = freezed,
    Object? quality = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$SleepEntryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      babyId: null == babyId
          ? _value.babyId
          : babyId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SleepType,
      durationMinutes: freezed == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      quality: freezed == quality
          ? _value.quality
          : quality // ignore: cast_nullable_to_non_nullable
              as SleepQuality?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SleepEntryImpl extends _SleepEntry {
  const _$SleepEntryImpl(
      {required this.id,
      required this.babyId,
      required this.userId,
      required this.startTime,
      this.endTime,
      required this.type,
      this.durationMinutes,
      this.quality,
      this.notes,
      required this.createdAt})
      : super._();

  factory _$SleepEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$SleepEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String babyId;
  @override
  final String userId;
  @override
  final DateTime startTime;
  @override
  final DateTime? endTime;
  @override
  final SleepType type;
  @override
  final int? durationMinutes;
  @override
  final SleepQuality? quality;
  @override
  final String? notes;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'SleepEntry(id: $id, babyId: $babyId, userId: $userId, startTime: $startTime, endTime: $endTime, type: $type, durationMinutes: $durationMinutes, quality: $quality, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SleepEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.babyId, babyId) || other.babyId == babyId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.quality, quality) || other.quality == quality) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, babyId, userId, startTime,
      endTime, type, durationMinutes, quality, notes, createdAt);

  /// Create a copy of SleepEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SleepEntryImplCopyWith<_$SleepEntryImpl> get copyWith =>
      __$$SleepEntryImplCopyWithImpl<_$SleepEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SleepEntryImplToJson(
      this,
    );
  }
}

abstract class _SleepEntry extends SleepEntry {
  const factory _SleepEntry(
      {required final String id,
      required final String babyId,
      required final String userId,
      required final DateTime startTime,
      final DateTime? endTime,
      required final SleepType type,
      final int? durationMinutes,
      final SleepQuality? quality,
      final String? notes,
      required final DateTime createdAt}) = _$SleepEntryImpl;
  const _SleepEntry._() : super._();

  factory _SleepEntry.fromJson(Map<String, dynamic> json) =
      _$SleepEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get babyId;
  @override
  String get userId;
  @override
  DateTime get startTime;
  @override
  DateTime? get endTime;
  @override
  SleepType get type;
  @override
  int? get durationMinutes;
  @override
  SleepQuality? get quality;
  @override
  String? get notes;
  @override
  DateTime get createdAt;

  /// Create a copy of SleepEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SleepEntryImplCopyWith<_$SleepEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
