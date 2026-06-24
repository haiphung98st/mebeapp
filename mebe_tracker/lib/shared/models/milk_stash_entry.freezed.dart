// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'milk_stash_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MilkStashEntry _$MilkStashEntryFromJson(Map<String, dynamic> json) {
  return _MilkStashEntry.fromJson(json);
}

/// @nodoc
mixin _$MilkStashEntry {
  String get id => throw _privateConstructorUsedError;
  String get babyId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get pumpedAt => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  double get amountMl => throw _privateConstructorUsedError;
  StashLocation get location => throw _privateConstructorUsedError;
  bool get isUsed => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this MilkStashEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MilkStashEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MilkStashEntryCopyWith<MilkStashEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MilkStashEntryCopyWith<$Res> {
  factory $MilkStashEntryCopyWith(
          MilkStashEntry value, $Res Function(MilkStashEntry) then) =
      _$MilkStashEntryCopyWithImpl<$Res, MilkStashEntry>;
  @useResult
  $Res call(
      {String id,
      String babyId,
      String userId,
      DateTime pumpedAt,
      DateTime? expiresAt,
      double amountMl,
      StashLocation location,
      bool isUsed,
      DateTime createdAt});
}

/// @nodoc
class _$MilkStashEntryCopyWithImpl<$Res, $Val extends MilkStashEntry>
    implements $MilkStashEntryCopyWith<$Res> {
  _$MilkStashEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MilkStashEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? babyId = null,
    Object? userId = null,
    Object? pumpedAt = null,
    Object? expiresAt = freezed,
    Object? amountMl = null,
    Object? location = null,
    Object? isUsed = null,
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
      pumpedAt: null == pumpedAt
          ? _value.pumpedAt
          : pumpedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      amountMl: null == amountMl
          ? _value.amountMl
          : amountMl // ignore: cast_nullable_to_non_nullable
              as double,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as StashLocation,
      isUsed: null == isUsed
          ? _value.isUsed
          : isUsed // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MilkStashEntryImplCopyWith<$Res>
    implements $MilkStashEntryCopyWith<$Res> {
  factory _$$MilkStashEntryImplCopyWith(_$MilkStashEntryImpl value,
          $Res Function(_$MilkStashEntryImpl) then) =
      __$$MilkStashEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String babyId,
      String userId,
      DateTime pumpedAt,
      DateTime? expiresAt,
      double amountMl,
      StashLocation location,
      bool isUsed,
      DateTime createdAt});
}

/// @nodoc
class __$$MilkStashEntryImplCopyWithImpl<$Res>
    extends _$MilkStashEntryCopyWithImpl<$Res, _$MilkStashEntryImpl>
    implements _$$MilkStashEntryImplCopyWith<$Res> {
  __$$MilkStashEntryImplCopyWithImpl(
      _$MilkStashEntryImpl _value, $Res Function(_$MilkStashEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of MilkStashEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? babyId = null,
    Object? userId = null,
    Object? pumpedAt = null,
    Object? expiresAt = freezed,
    Object? amountMl = null,
    Object? location = null,
    Object? isUsed = null,
    Object? createdAt = null,
  }) {
    return _then(_$MilkStashEntryImpl(
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
      pumpedAt: null == pumpedAt
          ? _value.pumpedAt
          : pumpedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      amountMl: null == amountMl
          ? _value.amountMl
          : amountMl // ignore: cast_nullable_to_non_nullable
              as double,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as StashLocation,
      isUsed: null == isUsed
          ? _value.isUsed
          : isUsed // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MilkStashEntryImpl extends _MilkStashEntry {
  const _$MilkStashEntryImpl(
      {required this.id,
      required this.babyId,
      required this.userId,
      required this.pumpedAt,
      this.expiresAt,
      required this.amountMl,
      required this.location,
      required this.isUsed,
      required this.createdAt})
      : super._();

  factory _$MilkStashEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$MilkStashEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String babyId;
  @override
  final String userId;
  @override
  final DateTime pumpedAt;
  @override
  final DateTime? expiresAt;
  @override
  final double amountMl;
  @override
  final StashLocation location;
  @override
  final bool isUsed;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'MilkStashEntry(id: $id, babyId: $babyId, userId: $userId, pumpedAt: $pumpedAt, expiresAt: $expiresAt, amountMl: $amountMl, location: $location, isUsed: $isUsed, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MilkStashEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.babyId, babyId) || other.babyId == babyId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.pumpedAt, pumpedAt) ||
                other.pumpedAt == pumpedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.amountMl, amountMl) ||
                other.amountMl == amountMl) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.isUsed, isUsed) || other.isUsed == isUsed) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, babyId, userId, pumpedAt,
      expiresAt, amountMl, location, isUsed, createdAt);

  /// Create a copy of MilkStashEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MilkStashEntryImplCopyWith<_$MilkStashEntryImpl> get copyWith =>
      __$$MilkStashEntryImplCopyWithImpl<_$MilkStashEntryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MilkStashEntryImplToJson(
      this,
    );
  }
}

abstract class _MilkStashEntry extends MilkStashEntry {
  const factory _MilkStashEntry(
      {required final String id,
      required final String babyId,
      required final String userId,
      required final DateTime pumpedAt,
      final DateTime? expiresAt,
      required final double amountMl,
      required final StashLocation location,
      required final bool isUsed,
      required final DateTime createdAt}) = _$MilkStashEntryImpl;
  const _MilkStashEntry._() : super._();

  factory _MilkStashEntry.fromJson(Map<String, dynamic> json) =
      _$MilkStashEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get babyId;
  @override
  String get userId;
  @override
  DateTime get pumpedAt;
  @override
  DateTime? get expiresAt;
  @override
  double get amountMl;
  @override
  StashLocation get location;
  @override
  bool get isUsed;
  @override
  DateTime get createdAt;

  /// Create a copy of MilkStashEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MilkStashEntryImplCopyWith<_$MilkStashEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
