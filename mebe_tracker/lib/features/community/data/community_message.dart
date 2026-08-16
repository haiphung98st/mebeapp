import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityMessage {
  const CommunityMessage({
    required this.id,
    required this.communityId,
    required this.userId,
    required this.displayName,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String communityId;
  final String userId;
  final String displayName; // anonymous display name
  final String text;
  final DateTime createdAt;

  Map<String, dynamic> toFirestore() => {
        'communityId': communityId,
        'userId': userId,
        'displayName': displayName,
        'text': text,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory CommunityMessage.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    return CommunityMessage(
      id: doc.id,
      communityId: d['communityId'] as String,
      userId: d['userId'] as String,
      displayName: d['displayName'] as String,
      text: d['text'] as String,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }
}

// Compute ISO week community key from a date (e.g. "week_2024_W23")
String communityKeyForDate(DateTime date) {
  // ISO week: week containing Thursday of that week belongs to that year
  final thursday = date.add(Duration(days: 4 - date.weekday));
  final week = _isoWeek(date);
  return 'week_${thursday.year}_W${week.toString().padLeft(2, '0')}';
}

int _isoWeek(DateTime date) {
  final startOfYear = DateTime(date.year, 1, 1);
  final dayOfYear = date.difference(startOfYear).inDays + 1;
  final weekDay = date.weekday; // 1 = Mon
  // ISO week number
  final week = ((dayOfYear - weekDay + 10) / 7).floor();
  if (week < 1) return _isoWeek(DateTime(date.year - 1, 12, 28)) + 1;
  final weeksInYear = _weeksInYear(date.year);
  if (week > weeksInYear) return 1;
  return week;
}

int _weeksInYear(int year) {
  final dec28 = DateTime(year, 12, 28);
  return _isoWeek(dec28);
}
