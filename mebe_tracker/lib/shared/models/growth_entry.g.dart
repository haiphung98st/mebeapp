// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GrowthEntryImpl _$$GrowthEntryImplFromJson(Map<String, dynamic> json) =>
    _$GrowthEntryImpl(
      id: json['id'] as String,
      babyId: json['babyId'] as String,
      userId: json['userId'] as String,
      measuredAt: DateTime.parse(json['measuredAt'] as String),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      headCircumferenceCm: (json['headCircumferenceCm'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$GrowthEntryImplToJson(_$GrowthEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'babyId': instance.babyId,
      'userId': instance.userId,
      'measuredAt': instance.measuredAt.toIso8601String(),
      'weightKg': instance.weightKg,
      'heightCm': instance.heightCm,
      'headCircumferenceCm': instance.headCircumferenceCm,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };
