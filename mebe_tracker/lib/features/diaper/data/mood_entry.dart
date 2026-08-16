import 'package:cloud_firestore/cloud_firestore.dart';

enum BabyMood { happy, calm, sleepy, fussy, crying }

extension BabyMoodX on BabyMood {
  String get emoji {
    switch (this) {
      case BabyMood.happy: return '😊';
      case BabyMood.calm: return '😌';
      case BabyMood.sleepy: return '😴';
      case BabyMood.fussy: return '😤';
      case BabyMood.crying: return '😢';
    }
  }

  String get label {
    switch (this) {
      case BabyMood.happy: return 'Vui vẻ';
      case BabyMood.calm: return 'Bình tĩnh';
      case BabyMood.sleepy: return 'Buồn ngủ';
      case BabyMood.fussy: return 'Quấy khóc';
      case BabyMood.crying: return 'Khóc nhiều';
    }
  }

  String get name => toString().split('.').last;
}

BabyMood moodFromString(String s) =>
    BabyMood.values.firstWhere((m) => m.name == s, orElse: () => BabyMood.calm);

class MoodEntry {
  const MoodEntry({
    required this.id,
    required this.babyId,
    required this.userId,
    required this.mood,
    required this.time,
    this.notes,
  });

  final String id;
  final String babyId;
  final String userId;
  final BabyMood mood;
  final DateTime time;
  final String? notes;

  factory MoodEntry.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return MoodEntry(
      id: doc.id,
      babyId: data['babyId'] as String,
      userId: data['userId'] as String,
      mood: moodFromString(data['mood'] as String),
      time: (data['time'] as Timestamp).toDate(),
      notes: data['notes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'babyId': babyId,
    'userId': userId,
    'mood': mood.name,
    'time': Timestamp.fromDate(time),
    if (notes != null) 'notes': notes,
  };
}
