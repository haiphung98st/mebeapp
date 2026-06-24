// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SleepEntryImpl _$$SleepEntryImplFromJson(Map<String, dynamic> json) =>
    _$SleepEntryImpl(
      id: json['id'] as String,
      babyId: json['babyId'] as String,
      userId: json['userId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      type: $enumDecode(_$SleepTypeEnumMap, json['type']),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      quality: $enumDecodeNullable(_$SleepQualityEnumMap, json['quality']),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$SleepEntryImplToJson(_$SleepEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'babyId': instance.babyId,
      'userId': instance.userId,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'type': _$SleepTypeEnumMap[instance.type]!,
      'durationMinutes': instance.durationMinutes,
      'quality': _$SleepQualityEnumMap[instance.quality],
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$SleepTypeEnumMap = {
  SleepType.night: 'night',
  SleepType.nap: 'nap',
};

const _$SleepQualityEnumMap = {
  SleepQuality.good: 'good',
  SleepQuality.fair: 'fair',
  SleepQuality.poor: 'poor',
};
