// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diaper_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DiaperEntry _$DiaperEntryFromJson(Map<String, dynamic> json) {
  return _DiaperEntry.fromJson(json);
}

/// @nodoc
mixin _$DiaperEntry {
  String get id => throw _privateConstructorUsedError;
  String get babyId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get time => throw _privateConstructorUsedError;
  DiaperType get type => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this DiaperEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DiaperEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiaperEntryCopyWith<DiaperEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiaperEntryCopyWith<$Res> {
  factory $DiaperEntryCopyWith(
          DiaperEntry value, $Res Function(DiaperEntry) then) =
      _$DiaperEntryCopyWithImpl<$Res, DiaperEntry>;
  @useResult
  $Res call(
      {String id,
      String babyId,
      String userId,
      DateTime time,
      DiaperType type,
      String? color,
      String? notes,
      DateTime createdAt});
}

/// @nodoc
class _$DiaperEntryCopyWithImpl<$Res, $Val extends DiaperEntry>
    implements $DiaperEntryCopyWith<$Res> {
  _$DiaperEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiaperEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? babyId = null,
    Object? userId = null,
    Object? time = null,
    Object? type = null,
    Object? color = freezed,
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
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DiaperType,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
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
abstract class _$$DiaperEntryImplCopyWith<$Res>
    implements $DiaperEntryCopyWith<$Res> {
  factory _$$DiaperEntryImplCopyWith(
          _$DiaperEntryImpl value, $Res Function(_$DiaperEntryImpl) then) =
      __$$DiaperEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String babyId,
      String userId,
      DateTime time,
      DiaperType type,
      String? color,
      String? notes,
      DateTime createdAt});
}

/// @nodoc
class __$$DiaperEntryImplCopyWithImpl<$Res>
    extends _$DiaperEntryCopyWithImpl<$Res, _$DiaperEntryImpl>
    implements _$$DiaperEntryImplCopyWith<$Res> {
  __$$DiaperEntryImplCopyWithImpl(
      _$DiaperEntryImpl _value, $Res Function(_$DiaperEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of DiaperEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? babyId = null,
    Object? userId = null,
    Object? time = null,
    Object? type = null,
    Object? color = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$DiaperEntryImpl(
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
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DiaperType,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
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
class _$DiaperEntryImpl extends _DiaperEntry {
  const _$DiaperEntryImpl(
      {required this.id,
      required this.babyId,
      required this.userId,
      required this.time,
      required this.type,
      this.color,
      this.notes,
      required this.createdAt})
      : super._();

  factory _$DiaperEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiaperEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String babyId;
  @override
  final String userId;
  @override
  final DateTime time;
  @override
  final DiaperType type;
  @override
  final String? color;
  @override
  final String? notes;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'DiaperEntry(id: $id, babyId: $babyId, userId: $userId, time: $time, type: $type, color: $color, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiaperEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.babyId, babyId) || other.babyId == babyId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, babyId, userId, time, type, color, notes, createdAt);

  /// Create a copy of DiaperEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiaperEntryImplCopyWith<_$DiaperEntryImpl> get copyWith =>
      __$$DiaperEntryImplCopyWithImpl<_$DiaperEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DiaperEntryImplToJson(
      this,
    );
  }
}

abstract class _DiaperEntry extends DiaperEntry {
  const factory _DiaperEntry(
      {required final String id,
      required final String babyId,
      required final String userId,
      required final DateTime time,
      required final DiaperType type,
      final String? color,
      final String? notes,
      required final DateTime createdAt}) = _$DiaperEntryImpl;
  const _DiaperEntry._() : super._();

  factory _DiaperEntry.fromJson(Map<String, dynamic> json) =
      _$DiaperEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get babyId;
  @override
  String get userId;
  @override
  DateTime get time;
  @override
  DiaperType get type;
  @override
  String? get color;
  @override
  String? get notes;
  @override
  DateTime get createdAt;

  /// Create a copy of DiaperEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiaperEntryImplCopyWith<_$DiaperEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
