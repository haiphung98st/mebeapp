import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'milk_stash_entry.freezed.dart';
part 'milk_stash_entry.g.dart';

enum StashLocation { fridge, freezer }

@freezed
class MilkStashEntry with _$MilkStashEntry {
  const factory MilkStashEntry({
    required String id,
    required String babyId,
    required String userId,
    required DateTime pumpedAt,
    DateTime? expiresAt,
    required double amountMl,
    required StashLocation location,
    required bool isUsed,
    required DateTime createdAt,
  }) = _MilkStashEntry;

  const MilkStashEntry._();

  factory MilkStashEntry.fromJson(Map<String, dynamic> json) =>
      _$MilkStashEntryFromJson(json);

  factory MilkStashEntry.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return MilkStashEntry.fromJson({
      ...data,
      'id': doc.id,
      'pumpedAt': (data['pumpedAt'] as Timestamp).toDate().toIso8601String(),
      'expiresAt': (data['expiresAt'] as Timestamp?)?.toDate().toIso8601String(),
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson()..remove('id');
    json['pumpedAt'] = Timestamp.fromDate(pumpedAt);
    json['expiresAt'] = expiresAt != null ? Timestamp.fromDate(expiresAt!) : null;
    json['createdAt'] = Timestamp.fromDate(createdAt);
    return json;
  }
}
