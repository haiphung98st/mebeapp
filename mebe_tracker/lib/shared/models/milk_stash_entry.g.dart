// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'milk_stash_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MilkStashEntryImpl _$$MilkStashEntryImplFromJson(Map<String, dynamic> json) =>
    _$MilkStashEntryImpl(
      id: json['id'] as String,
      babyId: json['babyId'] as String,
      userId: json['userId'] as String,
      pumpedAt: DateTime.parse(json['pumpedAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      amountMl: (json['amountMl'] as num).toDouble(),
      location: $enumDecode(_$StashLocationEnumMap, json['location']),
      isUsed: json['isUsed'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$MilkStashEntryImplToJson(
        _$MilkStashEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'babyId': instance.babyId,
      'userId': instance.userId,
      'pumpedAt': instance.pumpedAt.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'amountMl': instance.amountMl,
      'location': _$StashLocationEnumMap[instance.location]!,
      'isUsed': instance.isUsed,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$StashLocationEnumMap = {
  StashLocation.fridge: 'fridge',
  StashLocation.freezer: 'freezer',
};
