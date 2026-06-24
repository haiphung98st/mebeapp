import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'growth_entry.freezed.dart';
part 'growth_entry.g.dart';

@freezed
class GrowthEntry with _$GrowthEntry {
  const factory GrowthEntry({
    required String id,
    required String babyId,
    required String userId,
    required DateTime measuredAt,
    double? weightKg,
    double? heightCm,
    double? headCircumferenceCm,
    String? notes,
    required DateTime createdAt,
  }) = _GrowthEntry;

  const GrowthEntry._();

  factory GrowthEntry.fromJson(Map<String, dynamic> json) =>
      _$GrowthEntryFromJson(json);

  factory GrowthEntry.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return GrowthEntry.fromJson({
      ...data,
      'id': doc.id,
      'measuredAt': (data['measuredAt'] as Timestamp).toDate().toIso8601String(),
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson()..remove('id');
    json['measuredAt'] = Timestamp.fromDate(measuredAt);
    json['createdAt'] = Timestamp.fromDate(createdAt);
    return json;
  }
}
