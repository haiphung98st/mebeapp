import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'vaccine_entry.freezed.dart';
part 'vaccine_entry.g.dart';

@freezed
class VaccineEntry with _$VaccineEntry {
  const factory VaccineEntry({
    required String id,
    required String babyId,
    required String vaccineKey,
    required String nameVi,
    required DateTime scheduledDate,
    DateTime? administeredDate,
    required bool isCompleted,
    String? clinicName,
    String? notes,
    required DateTime createdAt,
  }) = _VaccineEntry;

  const VaccineEntry._();

  factory VaccineEntry.fromJson(Map<String, dynamic> json) =>
      _$VaccineEntryFromJson(json);

  factory VaccineEntry.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return VaccineEntry.fromJson({
      ...data,
      'id': doc.id,
      'scheduledDate': (data['scheduledDate'] as Timestamp).toDate().toIso8601String(),
      'administeredDate': (data['administeredDate'] as Timestamp?)?.toDate().toIso8601String(),
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson()..remove('id');
    json['scheduledDate'] = Timestamp.fromDate(scheduledDate);
    json['administeredDate'] =
        administeredDate != null ? Timestamp.fromDate(administeredDate!) : null;
    json['createdAt'] = Timestamp.fromDate(createdAt);
    return json;
  }
}
