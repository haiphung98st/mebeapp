// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vaccine_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VaccineEntry _$VaccineEntryFromJson(Map<String, dynamic> json) {
  return _VaccineEntry.fromJson(json);
}

/// @nodoc
mixin _$VaccineEntry {
  String get id => throw _privateConstructorUsedError;
  String get babyId => throw _privateConstructorUsedError;
  String get vaccineKey => throw _privateConstructorUsedError;
  String get nameVi => throw _privateConstructorUsedError;
  DateTime get scheduledDate => throw _privateConstructorUsedError;
  DateTime? get administeredDate => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  String? get clinicName => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this VaccineEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VaccineEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VaccineEntryCopyWith<VaccineEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VaccineEntryCopyWith<$Res> {
  factory $VaccineEntryCopyWith(
          VaccineEntry value, $Res Function(VaccineEntry) then) =
      _$VaccineEntryCopyWithImpl<$Res, VaccineEntry>;
  @useResult
  $Res call(
      {String id,
      String babyId,
      String vaccineKey,
      String nameVi,
      DateTime scheduledDate,
      DateTime? administeredDate,
      bool isCompleted,
      String? clinicName,
      String? notes,
      DateTime createdAt});
}

/// @nodoc
class _$VaccineEntryCopyWithImpl<$Res, $Val extends VaccineEntry>
    implements $VaccineEntryCopyWith<$Res> {
  _$VaccineEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VaccineEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? babyId = null,
    Object? vaccineKey = null,
    Object? nameVi = null,
    Object? scheduledDate = null,
    Object? administeredDate = freezed,
    Object? isCompleted = null,
    Object? clinicName = freezed,
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
      vaccineKey: null == vaccineKey
          ? _value.vaccineKey
          : vaccineKey // ignore: cast_nullable_to_non_nullable
              as String,
      nameVi: null == nameVi
          ? _value.nameVi
          : nameVi // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledDate: null == scheduledDate
          ? _value.scheduledDate
          : scheduledDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      administeredDate: freezed == administeredDate
          ? _value.administeredDate
          : administeredDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      clinicName: freezed == clinicName
          ? _value.clinicName
          : clinicName // ignore: cast_nullable_to_non_nullable
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
abstract class _$$VaccineEntryImplCopyWith<$Res>
    implements $VaccineEntryCopyWith<$Res> {
  factory _$$VaccineEntryImplCopyWith(
          _$VaccineEntryImpl value, $Res Function(_$VaccineEntryImpl) then) =
      __$$VaccineEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String babyId,
      String vaccineKey,
      String nameVi,
      DateTime scheduledDate,
      DateTime? administeredDate,
      bool isCompleted,
      String? clinicName,
      String? notes,
      DateTime createdAt});
}

/// @nodoc
class __$$VaccineEntryImplCopyWithImpl<$Res>
    extends _$VaccineEntryCopyWithImpl<$Res, _$VaccineEntryImpl>
    implements _$$VaccineEntryImplCopyWith<$Res> {
  __$$VaccineEntryImplCopyWithImpl(
      _$VaccineEntryImpl _value, $Res Function(_$VaccineEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of VaccineEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? babyId = null,
    Object? vaccineKey = null,
    Object? nameVi = null,
    Object? scheduledDate = null,
    Object? administeredDate = freezed,
    Object? isCompleted = null,
    Object? clinicName = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$VaccineEntryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      babyId: null == babyId
          ? _value.babyId
          : babyId // ignore: cast_nullable_to_non_nullable
              as String,
      vaccineKey: null == vaccineKey
          ? _value.vaccineKey
          : vaccineKey // ignore: cast_nullable_to_non_nullable
              as String,
      nameVi: null == nameVi
          ? _value.nameVi
          : nameVi // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledDate: null == scheduledDate
          ? _value.scheduledDate
          : scheduledDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      administeredDate: freezed == administeredDate
          ? _value.administeredDate
          : administeredDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      clinicName: freezed == clinicName
          ? _value.clinicName
          : clinicName // ignore: cast_nullable_to_non_nullable
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
class _$VaccineEntryImpl extends _VaccineEntry {
  const _$VaccineEntryImpl(
      {required this.id,
      required this.babyId,
      required this.vaccineKey,
      required this.nameVi,
      required this.scheduledDate,
      this.administeredDate,
      required this.isCompleted,
      this.clinicName,
      this.notes,
      required this.createdAt})
      : super._();

  factory _$VaccineEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$VaccineEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String babyId;
  @override
  final String vaccineKey;
  @override
  final String nameVi;
  @override
  final DateTime scheduledDate;
  @override
  final DateTime? administeredDate;
  @override
  final bool isCompleted;
  @override
  final String? clinicName;
  @override
  final String? notes;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'VaccineEntry(id: $id, babyId: $babyId, vaccineKey: $vaccineKey, nameVi: $nameVi, scheduledDate: $scheduledDate, administeredDate: $administeredDate, isCompleted: $isCompleted, clinicName: $clinicName, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VaccineEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.babyId, babyId) || other.babyId == babyId) &&
            (identical(other.vaccineKey, vaccineKey) ||
                other.vaccineKey == vaccineKey) &&
            (identical(other.nameVi, nameVi) || other.nameVi == nameVi) &&
            (identical(other.scheduledDate, scheduledDate) ||
                other.scheduledDate == scheduledDate) &&
            (identical(other.administeredDate, administeredDate) ||
                other.administeredDate == administeredDate) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.clinicName, clinicName) ||
                other.clinicName == clinicName) &&
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
      vaccineKey,
      nameVi,
      scheduledDate,
      administeredDate,
      isCompleted,
      clinicName,
      notes,
      createdAt);

  /// Create a copy of VaccineEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VaccineEntryImplCopyWith<_$VaccineEntryImpl> get copyWith =>
      __$$VaccineEntryImplCopyWithImpl<_$VaccineEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VaccineEntryImplToJson(
      this,
    );
  }
}

abstract class _VaccineEntry extends VaccineEntry {
  const factory _VaccineEntry(
      {required final String id,
      required final String babyId,
      required final String vaccineKey,
      required final String nameVi,
      required final DateTime scheduledDate,
      final DateTime? administeredDate,
      required final bool isCompleted,
      final String? clinicName,
      final String? notes,
      required final DateTime createdAt}) = _$VaccineEntryImpl;
  const _VaccineEntry._() : super._();

  factory _VaccineEntry.fromJson(Map<String, dynamic> json) =
      _$VaccineEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get babyId;
  @override
  String get vaccineKey;
  @override
  String get nameVi;
  @override
  DateTime get scheduledDate;
  @override
  DateTime? get administeredDate;
  @override
  bool get isCompleted;
  @override
  String? get clinicName;
  @override
  String? get notes;
  @override
  DateTime get createdAt;

  /// Create a copy of VaccineEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VaccineEntryImplCopyWith<_$VaccineEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
