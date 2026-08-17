import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityStatEntry {
  const CommunityStatEntry({
    required this.weekKey,
    required this.hashedUserId,
    required this.date,
    required this.feedingCount,
    required this.totalSleepMinutes,
    required this.diaperCount,
  });

  final String weekKey;
  final String hashedUserId;
  final String date; // YYYY-MM-DD

  final int feedingCount;
  final int totalSleepMinutes;
  final int diaperCount;

  String get docId => '${date}_$hashedUserId';

  Map<String, dynamic> toFirestore() => {
        'weekKey': weekKey,
        'hashedUserId': hashedUserId,
        'date': date,
        'feedingCount': feedingCount,
        'totalSleepMinutes': totalSleepMinutes,
        'diaperCount': diaperCount,
        'updatedAt': Timestamp.now(),
      };

  factory CommunityStatEntry.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return CommunityStatEntry(
      weekKey: d['weekKey'] as String? ?? '',
      hashedUserId: d['hashedUserId'] as String? ?? '',
      date: d['date'] as String? ?? '',
      feedingCount: (d['feedingCount'] as num?)?.toInt() ?? 0,
      totalSleepMinutes: (d['totalSleepMinutes'] as num?)?.toInt() ?? 0,
      diaperCount: (d['diaperCount'] as num?)?.toInt() ?? 0,
    );
  }
}
