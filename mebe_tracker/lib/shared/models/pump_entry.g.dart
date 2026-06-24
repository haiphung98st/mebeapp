// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pump_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PumpEntryImpl _$$PumpEntryImplFromJson(Map<String, dynamic> json) =>
    _$PumpEntryImpl(
      id: json['id'] as String,
      babyId: json['babyId'] as String,
      userId: json['userId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      leftAmountMl: (json['leftAmountMl'] as num?)?.toDouble(),
      rightAmountMl: (json['rightAmountMl'] as num?)?.toDouble(),
      leftDurationMinutes: (json['leftDurationMinutes'] as num?)?.toInt(),
      rightDurationMinutes: (json['rightDurationMinutes'] as num?)?.toInt(),
      storage: $enumDecode(_$PumpStorageEnumMap, json['storage']),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$PumpEntryImplToJson(_$PumpEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'babyId': instance.babyId,
      'userId': instance.userId,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'leftAmountMl': instance.leftAmountMl,
      'rightAmountMl': instance.rightAmountMl,
      'leftDurationMinutes': instance.leftDurationMinutes,
      'rightDurationMinutes': instance.rightDurationMinutes,
      'storage': _$PumpStorageEnumMap[instance.storage]!,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$PumpStorageEnumMap = {
  PumpStorage.fresh: 'fresh',
  PumpStorage.fridge: 'fridge',
  PumpStorage.frozen: 'frozen',
};
