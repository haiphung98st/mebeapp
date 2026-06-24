// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'milestone_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MilestoneEntryImpl _$$MilestoneEntryImplFromJson(Map<String, dynamic> json) =>
    _$MilestoneEntryImpl(
      id: json['id'] as String,
      babyId: json['babyId'] as String,
      milestoneKey: json['milestoneKey'] as String,
      titleVi: json['titleVi'] as String,
      achievedAt: json['achievedAt'] == null
          ? null
          : DateTime.parse(json['achievedAt'] as String),
      expectedWeekMin: (json['expectedWeekMin'] as num).toInt(),
      expectedWeekMax: (json['expectedWeekMax'] as num).toInt(),
      isAchieved: json['isAchieved'] as bool,
      photoUrl: json['photoUrl'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$MilestoneEntryImplToJson(
        _$MilestoneEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'babyId': instance.babyId,
      'milestoneKey': instance.milestoneKey,
      'titleVi': instance.titleVi,
      'achievedAt': instance.achievedAt?.toIso8601String(),
      'expectedWeekMin': instance.expectedWeekMin,
      'expectedWeekMax': instance.expectedWeekMax,
      'isAchieved': instance.isAchieved,
      'photoUrl': instance.photoUrl,
      'notes': instance.notes,
    };
