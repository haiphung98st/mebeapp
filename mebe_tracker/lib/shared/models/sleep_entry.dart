import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sleep_entry.freezed.dart';
part 'sleep_entry.g.dart';

enum SleepType { night, nap }

enum SleepQuality { good, fair, poor }

@freezed
class SleepEntry with _$SleepEntry {
  const factory SleepEntry({
    required String id,
    required String babyId,
    required String userId,
    required DateTime startTime,
    DateTime? endTime,
    required SleepType type,
    int? durationMinutes,
    SleepQuality? quality,
    String? notes,
    required DateTime createdAt,
  }) = _SleepEntry;

  const SleepEntry._();

  factory SleepEntry.fromJson(Map<String, dynamic> json) =>
      _$SleepEntryFromJson(json);

  factory SleepEntry.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return SleepEntry.fromJson({
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
