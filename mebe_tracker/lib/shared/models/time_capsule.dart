import 'package:cloud_firestore/cloud_firestore.dart';

class CapsuleItem {
  const CapsuleItem({
    required this.type,
    required this.titleVi,
    required this.contentVi,
    this.emoji,
  });

  final String type; // 'note'|'stat'|'milestone'|'wish'
  final String titleVi;
  final String contentVi;
  final String? emoji;

  Map<String, dynamic> toMap() => {
        'type': type,
        'titleVi': titleVi,
        'contentVi': contentVi,
        if (emoji != null) 'emoji': emoji,
      };

  factory CapsuleItem.fromMap(Map<String, dynamic> d) => CapsuleItem(
        type: d['type'] as String? ?? 'note',
        titleVi: d['titleVi'] as String? ?? '',
        contentVi: d['contentVi'] as String? ?? '',
        emoji: d['emoji'] as String?,
      );
}

class TimeCapsule {
  const TimeCapsule({
    required this.id,
    required this.babyId,
    required this.userId,
    required this.title,
    required this.unlockDate,
    required this.unlockAgeLabel,
    required this.createdAt,
    this.items = const [],
    this.isOpened = false,
    this.openedAt,
  });

  final String id;
  final String babyId;
  final String userId;
  final String title;
  final DateTime unlockDate;
  final String unlockAgeLabel;
  final DateTime createdAt;
  final List<CapsuleItem> items;
  final bool isOpened;
  final DateTime? openedAt;

  bool get isUnlocked => DateTime.now().isAfter(unlockDate);

  Duration get timeUntilUnlock => unlockDate.difference(DateTime.now());

  double get progressFraction {
    final total = unlockDate.difference(createdAt).inMinutes;
    if (total <= 0) return 1;
    final elapsed = DateTime.now().difference(createdAt).inMinutes;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toFirestore() => {
        'babyId': babyId,
        'userId': userId,
        'title': title,
        'unlockDate': Timestamp.fromDate(unlockDate),
        'unlockAgeLabel': unlockAgeLabel,
        'createdAt': Timestamp.fromDate(createdAt),
        'items': items.map((i) => i.toMap()).toList(),
        'isOpened': isOpened,
        if (openedAt != null) 'openedAt': Timestamp.fromDate(openedAt!),
      };

  factory TimeCapsule.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    final rawItems = d['items'] as List<dynamic>? ?? [];
    return TimeCapsule(
      id: doc.id,
      babyId: d['babyId'] as String,
      userId: d['userId'] as String,
      title: d['title'] as String? ?? '',
      unlockDate: (d['unlockDate'] as Timestamp).toDate(),
      unlockAgeLabel: d['unlockAgeLabel'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      items: rawItems
          .map((e) => CapsuleItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      isOpened: d['isOpened'] as bool? ?? false,
      openedAt: (d['openedAt'] as Timestamp?)?.toDate(),
    );
  }

  TimeCapsule copyWith({
    List<CapsuleItem>? items,
    bool? isOpened,
    DateTime? openedAt,
  }) =>
      TimeCapsule(
        id: id,
        babyId: babyId,
        userId: userId,
        title: title,
        unlockDate: unlockDate,
        unlockAgeLabel: unlockAgeLabel,
        createdAt: createdAt,
        items: items ?? this.items,
        isOpened: isOpened ?? this.isOpened,
        openedAt: openedAt ?? this.openedAt,
      );
}
