import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'diaper_entry.freezed.dart';
part 'diaper_entry.g.dart';

enum DiaperType { wet, dirty, both }

@freezed
class DiaperEntry with _$DiaperEntry {
  const factory DiaperEntry({
    required String id,
    required String babyId,
    required String userId,
    required DateTime time,
    required DiaperType type,
    String? color,
    String? notes,
    required DateTime createdAt,
  }) = _DiaperEntry;

  const DiaperEntry._();

  factory DiaperEntry.fromJson(Map<String, dynamic> json) =>
      _$DiaperEntryFromJson(json);

  factory DiaperEntry.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return DiaperEntry.fromJson({
      ...data,
      'id': doc.id,
      'time': (data['time'] as Timestamp).toDate().toIso8601String(),
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson()..remove('id');
    json['time'] = Timestamp.fromDate(time);
    json['createdAt'] = Timestamp.fromDate(createdAt);
    return json;
  }
}
