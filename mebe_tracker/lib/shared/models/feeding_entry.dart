import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'feeding_entry.freezed.dart';
part 'feeding_entry.g.dart';

enum FeedingType { breastLeft, breastRight, bottle, solid }

@freezed
class FeedingEntry with _$FeedingEntry {
  const factory FeedingEntry({
    required String id,
    required String babyId,
    required String userId,
    required FeedingType type,
    required DateTime startTime,
    DateTime? endTime,
    int? durationMinutes,
    double? amountMl,
    String? notes,
    required DateTime createdAt,
  }) = _FeedingEntry;

  const FeedingEntry._();

  factory FeedingEntry.fromJson(Map<String, dynamic> json) =>
      _$FeedingEntryFromJson(json);

  factory FeedingEntry.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return FeedingEntry.fromJson({
      ...data,
      'id': doc.id,
      'startTime': (data['startTime'] as Timestamp).toDate().toIso8601String(),
      'endTime': (data['endTime'] as Timestamp?)?.toDate().toIso8601String(),
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson()..remove('id');
    json['startTime'] = Timestamp.fromDate(startTime);
    json['endTime'] = endTime != null ? Timestamp.fromDate(endTime!) : null;
    json['createdAt'] = Timestamp.fromDate(createdAt);
    return json;
  }
}
