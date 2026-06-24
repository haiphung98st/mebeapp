// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vaccine_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VaccineEntryImpl _$$VaccineEntryImplFromJson(Map<String, dynamic> json) =>
    _$VaccineEntryImpl(
      id: json['id'] as String,
      babyId: json['babyId'] as String,
      vaccineKey: json['vaccineKey'] as String,
      nameVi: json['nameVi'] as String,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      administeredDate: json['administeredDate'] == null
          ? null
          : DateTime.parse(json['administeredDate'] as String),
      isCompleted: json['isCompleted'] as bool,
      clinicName: json['clinicName'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$VaccineEntryImplToJson(_$VaccineEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'babyId': instance.babyId,
      'vaccineKey': instance.vaccineKey,
      'nameVi': instance.nameVi,
      'scheduledDate': instance.scheduledDate.toIso8601String(),
      'administeredDate': instance.administeredDate?.toIso8601String(),
      'isCompleted': instance.isCompleted,
      'clinicName': instance.clinicName,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };
