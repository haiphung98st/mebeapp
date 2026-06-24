// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diaper_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DiaperEntryImpl _$$DiaperEntryImplFromJson(Map<String, dynamic> json) =>
    _$DiaperEntryImpl(
      id: json['id'] as String,
      babyId: json['babyId'] as String,
      userId: json['userId'] as String,
      time: DateTime.parse(json['time'] as String),
      type: $enumDecode(_$DiaperTypeEnumMap, json['type']),
      color: json['color'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$DiaperEntryImplToJson(_$DiaperEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'babyId': instance.babyId,
      'userId': instance.userId,
      'time': instance.time.toIso8601String(),
      'type': _$DiaperTypeEnumMap[instance.type]!,
      'color': instance.color,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$DiaperTypeEnumMap = {
  DiaperType.wet: 'wet',
  DiaperType.dirty: 'dirty',
  DiaperType.both: 'both',
};
