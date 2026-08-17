import 'package:cloud_firestore/cloud_firestore.dart';

class StoryCard {
  const StoryCard({
    required this.id,
    required this.babyId,
    required this.userId,
    required this.type,
    required this.titleVi,
    required this.contentVi,
    required this.theme,
    required this.cardDate,
    required this.createdAt,
    this.subtitle,
    this.achievementId,
    this.milestoneKey,
    this.isShared = false,
  });

  final String id;
  final String babyId;
  final String userId;
  final String type; // 'birthday'|'milestone'|'achievement'|'custom'
  final String titleVi;
  final String contentVi;
  final String theme; // 'blossom'|'lavender'|'mint'|'gold'
  final DateTime cardDate;
  final DateTime createdAt;
  final String? subtitle;
  final String? achievementId;
  final String? milestoneKey;
  final bool isShared;

  Map<String, dynamic> toFirestore() => {
        'babyId': babyId,
        'userId': userId,
        'type': type,
        'titleVi': titleVi,
        'contentVi': contentVi,
        'theme': theme,
        'cardDate': Timestamp.fromDate(cardDate),
        'createdAt': Timestamp.fromDate(createdAt),
        if (subtitle != null) 'subtitle': subtitle,
        if (achievementId != null) 'achievementId': achievementId,
        if (milestoneKey != null) 'milestoneKey': milestoneKey,
        'isShared': isShared,
      };

  factory StoryCard.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return StoryCard(
      id: doc.id,
      babyId: d['babyId'] as String,
      userId: d['userId'] as String,
      type: d['type'] as String? ?? 'custom',
      titleVi: d['titleVi'] as String? ?? '',
      contentVi: d['contentVi'] as String? ?? '',
      theme: d['theme'] as String? ?? 'blossom',
      cardDate: (d['cardDate'] as Timestamp).toDate(),
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      subtitle: d['subtitle'] as String?,
      achievementId: d['achievementId'] as String?,
      milestoneKey: d['milestoneKey'] as String?,
      isShared: d['isShared'] as bool? ?? false,
    );
  }
}
