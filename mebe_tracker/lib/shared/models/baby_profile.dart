import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'baby_profile.freezed.dart';
part 'baby_profile.g.dart';

@freezed
class BabyProfile with _$BabyProfile {
  const factory BabyProfile({
    required String id,
    required String userId,
    required String name,
    required DateTime dateOfBirth,
    required String gender,
    double? weightKg,
    double? heightCm,
    double? headCircumferenceCm,
    String? avatarUrl,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _BabyProfile;

  const BabyProfile._();

  factory BabyProfile.fromJson(Map<String, dynamic> json) =>
      _$BabyProfileFromJson(json);

  factory BabyProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return BabyProfile.fromJson({
      ...data,
      'id': doc.id,
      'dateOfBirth': (data['dateOfBirth'] as Timestamp).toDate().toIso8601String(),
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      'updatedAt': (data['updatedAt'] as Timestamp).toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson()..remove('id');
    json['dateOfBirth'] = Timestamp.fromDate(dateOfBirth);
    json['createdAt'] = Timestamp.fromDate(createdAt);
    json['updatedAt'] = Timestamp.fromDate(updatedAt);
    return json;
  }
}
