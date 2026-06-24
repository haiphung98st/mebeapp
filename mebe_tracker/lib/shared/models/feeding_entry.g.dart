// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feeding_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FeedingEntryImpl _$$FeedingEntryImplFromJson(Map<String, dynamic> json) =>
    _$FeedingEntryImpl(
      id: json['id'] as String,
      babyId: json['babyId'] as String,
      userId: json['userId'] as String,
      type: $enumDecode(_$FeedingTypeEnumMap, json['type']),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      amountMl: (json['amountMl'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$FeedingEntryImplToJson(_$FeedingEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'babyId': instance.babyId,
      'userId': instance.userId,
      'type': _$FeedingTypeEnumMap[instance.type]!,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
      'amountMl': instance.amountMl,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$FeedingTypeEnumMap = {
  FeedingType.breastLeft: 'breastLeft',
  FeedingType.breastRight: 'breastRight',
  FeedingType.bottle: 'bottle',
  FeedingType.solid: 'solid',
};
