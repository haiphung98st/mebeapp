import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pump_entry.freezed.dart';
part 'pump_entry.g.dart';

enum PumpStorage { fresh, fridge, frozen }

@freezed
class PumpEntry with _$PumpEntry {
  const factory PumpEntry({
    required String id,
    required String babyId,
    required String userId,
    required DateTime startTime,
    DateTime? endTime,
    double? leftAmountMl,
    double? rightAmountMl,
    int? leftDurationMinutes,
    int? rightDurationMinutes,
    required PumpStorage storage,
    String? notes,
    required DateTime createdAt,
  }) = _PumpEntry;

  const PumpEntry._();

  factory PumpEntry.fromJson(Map<String, dynamic> json) =>
      _$PumpEntryFromJson(json);

  factory PumpEntry.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return PumpEntry.fromJson({
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
