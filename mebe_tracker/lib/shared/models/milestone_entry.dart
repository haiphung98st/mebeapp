import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'milestone_entry.freezed.dart';
part 'milestone_entry.g.dart';

@freezed
class MilestoneEntry with _$MilestoneEntry {
  const factory MilestoneEntry({
    required String id,
    required String babyId,
    required String milestoneKey,
    required String titleVi,
    DateTime? achievedAt,
    required int expectedWeekMin,
    required int expectedWeekMax,
    required bool isAchieved,
    String? photoUrl,
    String? notes,
  }) = _MilestoneEntry;

  const MilestoneEntry._();

  factory MilestoneEntry.fromJson(Map<String, dynamic> json) =>
      _$MilestoneEntryFromJson(json);

  factory MilestoneEntry.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return MilestoneEntry.fromJson({
      ...data,
      'id': doc.id,
      'achievedAt': (data['achievedAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson()..remove('id');
    json['achievedAt'] = achievedAt != null ? Timestamp.fromDate(achievedAt!) : null;
    return json;
  }
}
