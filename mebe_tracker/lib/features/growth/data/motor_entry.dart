import 'package:cloud_firestore/cloud_firestore.dart';

enum BabyActivity {
  tummyTime,
  sitting,
  crawling,
  standing,
  walking,
  stretching,
  playTime,
}

extension BabyActivityX on BabyActivity {
  String get emoji {
    switch (this) {
      case BabyActivity.tummyTime: return '🐢';
      case BabyActivity.sitting: return '🧘';
      case BabyActivity.crawling: return '🦎';
      case BabyActivity.standing: return '🧍';
      case BabyActivity.walking: return '👣';
      case BabyActivity.stretching: return '🤸';
      case BabyActivity.playTime: return '🧸';
    }
  }

  String get label {
    switch (this) {
      case BabyActivity.tummyTime: return 'Nằm sấp';
      case BabyActivity.sitting: return 'Ngồi';
      case BabyActivity.crawling: return 'Bò';
      case BabyActivity.standing: return 'Đứng';
      case BabyActivity.walking: return 'Đi bộ';
      case BabyActivity.stretching: return 'Vươn người';
      case BabyActivity.playTime: return 'Vui chơi';
    }
  }

  String get name => toString().split('.').last;
}

BabyActivity activityFromString(String s) =>
    BabyActivity.values.firstWhere((a) => a.name == s,
        orElse: () => BabyActivity.tummyTime);

class MotorEntry {
  const MotorEntry({
    required this.id,
    required this.babyId,
    required this.userId,
    required this.activity,
    required this.startTime,
    required this.durationSeconds,
    this.notes,
  });

  final String id;
  final String babyId;
  final String userId;
  final BabyActivity activity;
  final DateTime startTime;
  final int durationSeconds;
  final String? notes;

  factory MotorEntry.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return MotorEntry(
      id: doc.id,
      babyId: data['babyId'] as String,
      userId: data['userId'] as String,
      activity: activityFromString(data['activity'] as String),
      startTime: (data['startTime'] as Timestamp).toDate(),
      durationSeconds: data['durationSeconds'] as int,
      notes: data['notes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'babyId': babyId,
    'userId': userId,
    'activity': activity.name,
    'startTime': Timestamp.fromDate(startTime),
    'durationSeconds': durationSeconds,
    if (notes != null) 'notes': notes,
  };
}
