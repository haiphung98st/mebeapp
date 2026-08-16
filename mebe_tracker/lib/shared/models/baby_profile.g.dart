// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'baby_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BabyProfileImpl _$$BabyProfileImplFromJson(Map<String, dynamic> json) =>
    _$BabyProfileImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      gender: json['gender'] as String,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      headCircumferenceCm: (json['headCircumferenceCm'] as num?)?.toDouble(),
      avatarUrl: json['avatarUrl'] as String?,
      edd: json['edd'] == null ? null : DateTime.parse(json['edd'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$BabyProfileImplToJson(_$BabyProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'gender': instance.gender,
      'weightKg': instance.weightKg,
      'heightCm': instance.heightCm,
      'headCircumferenceCm': instance.headCircumferenceCm,
      'avatarUrl': instance.avatarUrl,
      'edd': instance.edd?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
