// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pump_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PumpEntry _$PumpEntryFromJson(Map<String, dynamic> json) {
  return _PumpEntry.fromJson(json);
}

/// @nodoc
mixin _$PumpEntry {
  String get id => throw _privateConstructorUsedError;
  String get babyId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;
  double? get leftAmountMl => throw _privateConstructorUsedError;
  double? get rightAmountMl => throw _privateConstructorUsedError;
  int? get leftDurationMinutes => throw _privateConstructorUsedError;
  int? get rightDurationMinutes => throw _privateConstructorUsedError;
  PumpStorage get storage => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this PumpEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PumpEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PumpEntryCopyWith<PumpEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PumpEntryCopyWith<$Res> {
  factory $PumpEntryCopyWith(PumpEntry value, $Res Function(PumpEntry) then) =
      _$PumpEntryCopyWithImpl<$Res, PumpEntry>;
  @useResult
  $Res call(
      {String id,
      String babyId,
      String userId,
      DateTime startTime,
      DateTime? endTime,
      double? leftAmountMl,
      double? rightAmountMl,
      int? leftDurationMinutes,
      int? rightDurationMinutes,
      PumpStorage storage,
      String? notes,
      DateTime createdAt});
}

/// @nodoc
class _$PumpEntryCopyWithImpl<$Res, $Val extends PumpEntry>
    implements $PumpEntryCopyWith<$Res> {
  _$PumpEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PumpEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? babyId = null,
    Object? userId = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? leftAmountMl = freezed,
    Object? rightAmountMl = freezed,
    Object? leftDurationMinutes = freezed,
    Object? rightDurationMinutes = freezed,
    Object? storage = null,
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
      leftAmountMl: freezed == leftAmountMl
          ? _value.leftAmountMl
          : leftAmountMl // ignore: cast_nullable_to_non_nullable
              as double?,
      rightAmountMl: freezed == rightAmountMl
          ? _value.rightAmountMl
          : rightAmountMl // ignore: cast_nullable_to_non_nullable
              as double?,
      leftDurationMinutes: freezed == leftDurationMinutes
          ? _value.leftDurationMinutes
          : leftDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      rightDurationMinutes: freezed == rightDurationMinutes
          ? _value.rightDurationMinutes
          : rightDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      storage: null == storage
          ? _value.storage
          : storage // ignore: cast_nullable_to_non_nullable
              as PumpStorage,
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
abstract class _$$PumpEntryImplCopyWith<$Res>
    implements $PumpEntryCopyWith<$Res> {
  factory _$$PumpEntryImplCopyWith(
          _$PumpEntryImpl value, $Res Function(_$PumpEntryImpl) then) =
      __$$PumpEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String babyId,
      String userId,
      DateTime startTime,
      DateTime? endTime,
      double? leftAmountMl,
      double? rightAmountMl,
      int? leftDurationMinutes,
      int? rightDurationMinutes,
      PumpStorage storage,
      String? notes,
      DateTime createdAt});
}

/// @nodoc
class __$$PumpEntryImplCopyWithImpl<$Res>
    extends _$PumpEntryCopyWithImpl<$Res, _$PumpEntryImpl>
    implements _$$PumpEntryImplCopyWith<$Res> {
  __$$PumpEntryImplCopyWithImpl(
      _$PumpEntryImpl _value, $Res Function(_$PumpEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of PumpEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? babyId = null,
    Object? userId = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? leftAmountMl = freezed,
    Object? rightAmountMl = freezed,
    Object? leftDurationMinutes = freezed,
    Object? rightDurationMinutes = freezed,
    Object? storage = null,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$PumpEntryImpl(
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
      leftAmountMl: freezed == leftAmountMl
          ? _value.leftAmountMl
          : leftAmountMl // ignore: cast_nullable_to_non_nullable
              as double?,
      rightAmountMl: freezed == rightAmountMl
          ? _value.rightAmountMl
          : rightAmountMl // ignore: cast_nullable_to_non_nullable
              as double?,
      leftDurationMinutes: freezed == leftDurationMinutes
          ? _value.leftDurationMinutes
          : leftDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      rightDurationMinutes: freezed == rightDurationMinutes
          ? _value.rightDurationMinutes
          : rightDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      storage: null == storage
          ? _value.storage
          : storage // ignore: cast_nullable_to_non_nullable
              as PumpStorage,
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
class _$PumpEntryImpl extends _PumpEntry {
  const _$PumpEntryImpl(
      {required this.id,
      required this.babyId,
      required this.userId,
      required this.startTime,
      this.endTime,
      this.leftAmountMl,
      this.rightAmountMl,
      this.leftDurationMinutes,
      this.rightDurationMinutes,
      required this.storage,
      this.notes,
      required this.createdAt})
      : super._();

  factory _$PumpEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PumpEntryImplFromJson(json);

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
  final double? leftAmountMl;
  @override
  final double? rightAmountMl;
  @override
  final int? leftDurationMinutes;
  @override
  final int? rightDurationMinutes;
  @override
  final PumpStorage storage;
  @override
  final String? notes;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'PumpEntry(id: $id, babyId: $babyId, userId: $userId, startTime: $startTime, endTime: $endTime, leftAmountMl: $leftAmountMl, rightAmountMl: $rightAmountMl, leftDurationMinutes: $leftDurationMinutes, rightDurationMinutes: $rightDurationMinutes, storage: $storage, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PumpEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.babyId, babyId) || other.babyId == babyId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.leftAmountMl, leftAmountMl) ||
                other.leftAmountMl == leftAmountMl) &&
            (identical(other.rightAmountMl, rightAmountMl) ||
                other.rightAmountMl == rightAmountMl) &&
            (identical(other.leftDurationMinutes, leftDurationMinutes) ||
                other.leftDurationMinutes == leftDurationMinutes) &&
            (identical(other.rightDurationMinutes, rightDurationMinutes) ||
                other.rightDurationMinutes == rightDurationMinutes) &&
            (identical(other.storage, storage) || other.storage == storage) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      babyId,
      userId,
      startTime,
      endTime,
      leftAmountMl,
      rightAmountMl,
      leftDurationMinutes,
      rightDurationMinutes,
      storage,
      notes,
      createdAt);

  /// Create a copy of PumpEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PumpEntryImplCopyWith<_$PumpEntryImpl> get copyWith =>
      __$$PumpEntryImplCopyWithImpl<_$PumpEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PumpEntryImplToJson(
      this,
    );
  }
}

abstract class _PumpEntry extends PumpEntry {
  const factory _PumpEntry(
      {required final String id,
      required final String babyId,
      required final String userId,
      required final DateTime startTime,
      final DateTime? endTime,
      final double? leftAmountMl,
      final double? rightAmountMl,
      final int? leftDurationMinutes,
      final int? rightDurationMinutes,
      required final PumpStorage storage,
      final String? notes,
      required final DateTime createdAt}) = _$PumpEntryImpl;
  const _PumpEntry._() : super._();

  factory _PumpEntry.fromJson(Map<String, dynamic> json) =
      _$PumpEntryImpl.fromJson;

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
  double? get leftAmountMl;
  @override
  double? get rightAmountMl;
  @override
  int? get leftDurationMinutes;
  @override
  int? get rightDurationMinutes;
  @override
  PumpStorage get storage;
  @override
  String? get notes;
  @override
  DateTime get createdAt;

  /// Create a copy of PumpEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PumpEntryImplCopyWith<_$PumpEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
