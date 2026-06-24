// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feeding_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FeedingEntry _$FeedingEntryFromJson(Map<String, dynamic> json) {
  return _FeedingEntry.fromJson(json);
}

/// @nodoc
mixin _$FeedingEntry {
  String get id => throw _privateConstructorUsedError;
  String get babyId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  FeedingType get type => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;
  int? get durationMinutes => throw _privateConstructorUsedError;
  double? get amountMl => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this FeedingEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeedingEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeedingEntryCopyWith<FeedingEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedingEntryCopyWith<$Res> {
  factory $FeedingEntryCopyWith(
          FeedingEntry value, $Res Function(FeedingEntry) then) =
      _$FeedingEntryCopyWithImpl<$Res, FeedingEntry>;
  @useResult
  $Res call(
      {String id,
      String babyId,
      String userId,
      FeedingType type,
      DateTime startTime,
      DateTime? endTime,
      int? durationMinutes,
      double? amountMl,
      String? notes,
      DateTime createdAt});
}

/// @nodoc
class _$FeedingEntryCopyWithImpl<$Res, $Val extends FeedingEntry>
    implements $FeedingEntryCopyWith<$Res> {
  _$FeedingEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedingEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? babyId = null,
    Object? userId = null,
    Object? type = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? durationMinutes = freezed,
    Object? amountMl = freezed,
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
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as FeedingType,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      durationMinutes: freezed == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      amountMl: freezed == amountMl
          ? _value.amountMl
          : amountMl // ignore: cast_nullable_to_non_nullable
              as double?,
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
abstract class _$$FeedingEntryImplCopyWith<$Res>
    implements $FeedingEntryCopyWith<$Res> {
  factory _$$FeedingEntryImplCopyWith(
          _$FeedingEntryImpl value, $Res Function(_$FeedingEntryImpl) then) =
      __$$FeedingEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String babyId,
      String userId,
      FeedingType type,
      DateTime startTime,
      DateTime? endTime,
      int? durationMinutes,
      double? amountMl,
      String? notes,
      DateTime createdAt});
}

/// @nodoc
class __$$FeedingEntryImplCopyWithImpl<$Res>
    extends _$FeedingEntryCopyWithImpl<$Res, _$FeedingEntryImpl>
    implements _$$FeedingEntryImplCopyWith<$Res> {
  __$$FeedingEntryImplCopyWithImpl(
      _$FeedingEntryImpl _value, $Res Function(_$FeedingEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeedingEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? babyId = null,
    Object? userId = null,
    Object? type = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? durationMinutes = freezed,
    Object? amountMl = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$FeedingEntryImpl(
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
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as FeedingType,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      durationMinutes: freezed == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      amountMl: freezed == amountMl
          ? _value.amountMl
          : amountMl // ignore: cast_nullable_to_non_nullable
              as double?,
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
class _$FeedingEntryImpl extends _FeedingEntry {
  const _$FeedingEntryImpl(
      {required this.id,
      required this.babyId,
      required this.userId,
      required this.type,
      required this.startTime,
      this.endTime,
      this.durationMinutes,
      this.amountMl,
      this.notes,
      required this.createdAt})
      : super._();

  factory _$FeedingEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeedingEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String babyId;
  @override
  final String userId;
  @override
  final FeedingType type;
  @override
  final DateTime startTime;
  @override
  final DateTime? endTime;
  @override
  final int? durationMinutes;
  @override
  final double? amountMl;
  @override
  final String? notes;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'FeedingEntry(id: $id, babyId: $babyId, userId: $userId, type: $type, startTime: $startTime, endTime: $endTime, durationMinutes: $durationMinutes, amountMl: $amountMl, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedingEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.babyId, babyId) || other.babyId == babyId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.amountMl, amountMl) ||
                other.amountMl == amountMl) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, babyId, userId, type,
      startTime, endTime, durationMinutes, amountMl, notes, createdAt);

  /// Create a copy of FeedingEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedingEntryImplCopyWith<_$FeedingEntryImpl> get copyWith =>
      __$$FeedingEntryImplCopyWithImpl<_$FeedingEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeedingEntryImplToJson(
      this,
    );
  }
}

abstract class _FeedingEntry extends FeedingEntry {
  const factory _FeedingEntry(
      {required final String id,
      required final String babyId,
      required final String userId,
      required final FeedingType type,
      required final DateTime startTime,
      final DateTime? endTime,
      final int? durationMinutes,
      final double? amountMl,
      final String? notes,
      required final DateTime createdAt}) = _$FeedingEntryImpl;
  const _FeedingEntry._() : super._();

  factory _FeedingEntry.fromJson(Map<String, dynamic> json) =
      _$FeedingEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get babyId;
  @override
  String get userId;
  @override
  FeedingType get type;
  @override
  DateTime get startTime;
  @override
  DateTime? get endTime;
  @override
  int? get durationMinutes;
  @override
  double? get amountMl;
  @override
  String? get notes;
  @override
  DateTime get createdAt;

  /// Create a copy of FeedingEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedingEntryImplCopyWith<_$FeedingEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
