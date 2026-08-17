import 'package:cloud_firestore/cloud_firestore.dart';

class FutureLetter {
  const FutureLetter({
    required this.id,
    required this.babyId,
    required this.userId,
    required this.title,
    required this.content,
    required this.unlockDate,
    required this.createdAt,
    this.isOpened = false,
    this.openedAt,
    this.unlockAgeLabel,
  });

  final String id;
  final String babyId;
  final String userId;
  final String title;
  final String content;
  final DateTime unlockDate;
  final DateTime createdAt;
  final bool isOpened;
  final DateTime? openedAt;
  final String? unlockAgeLabel;

  bool get isUnlocked => DateTime.now().isAfter(unlockDate);

  Duration get timeUntilUnlock =>
      unlockDate.difference(DateTime.now());

  Map<String, dynamic> toFirestore() => {
        'babyId': babyId,
        'userId': userId,
        'title': title,
        'content': content,
        'unlockDate': Timestamp.fromDate(unlockDate),
        'createdAt': Timestamp.fromDate(createdAt),
        'isOpened': isOpened,
        if (openedAt != null) 'openedAt': Timestamp.fromDate(openedAt!),
        if (unlockAgeLabel != null) 'unlockAgeLabel': unlockAgeLabel,
      };

  factory FutureLetter.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return FutureLetter(
      id: doc.id,
      babyId: d['babyId'] as String,
      userId: d['userId'] as String,
      title: d['title'] as String? ?? '',
      content: d['content'] as String? ?? '',
      unlockDate: (d['unlockDate'] as Timestamp).toDate(),
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      isOpened: d['isOpened'] as bool? ?? false,
      openedAt: (d['openedAt'] as Timestamp?)?.toDate(),
      unlockAgeLabel: d['unlockAgeLabel'] as String?,
    );
  }

  FutureLetter copyWith({bool? isOpened, DateTime? openedAt}) => FutureLetter(
        id: id,
        babyId: babyId,
        userId: userId,
        title: title,
        content: content,
        unlockDate: unlockDate,
        createdAt: createdAt,
        isOpened: isOpened ?? this.isOpened,
        openedAt: openedAt ?? this.openedAt,
        unlockAgeLabel: unlockAgeLabel,
      );
}
