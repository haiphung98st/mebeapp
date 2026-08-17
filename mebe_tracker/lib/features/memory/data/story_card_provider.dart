import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/baby_profile.dart';
import '../../../shared/models/story_card.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';

final _fs = FirebaseFirestore.instance;

CollectionReference<Map<String, dynamic>> _cardsCol(
        String userId, String babyId) =>
    _fs
        .collection('users')
        .doc(userId)
        .collection('babies')
        .doc(babyId)
        .collection('storyCards');

final storyCardsProvider = StreamProvider<List<StoryCard>>((ref) {
  final user = ref.watch(currentUserProvider);
  final baby = ref.watch(activeBabyProvider);
  if (user == null || baby == null) return Stream.value(const []);
  return _cardsCol(user.uid, baby.id)
      .orderBy('cardDate', descending: true)
      .limit(50)
      .snapshots()
      .map((s) => s.docs.map(StoryCard.fromFirestore).toList());
});

Future<void> saveStoryCard(String userId, String babyId, StoryCard card) =>
    _cardsCol(userId, babyId).doc(card.id).set(card.toFirestore());

Future<void> deleteStoryCard(
        String userId, String babyId, String cardId) =>
    _cardsCol(userId, babyId).doc(cardId).delete();

Future<bool> storyCardExists(
    String userId, String babyId, String cardId) async {
  final doc = await _cardsCol(userId, babyId).doc(cardId).get();
  return doc.exists;
}

StoryCard buildMilestoneCard({
  required String userId,
  required BabyProfile baby,
  required int ageInDays,
  required String title,
  required String theme,
}) {
  final now = DateTime.now();
  final months = ageInDays ~/ 30;
  final weight =
      baby.weightKg != null ? 'Nặng ${baby.weightKg!.toStringAsFixed(1)} kg' : '';
  final height =
      baby.heightCm != null ? '· Cao ${baby.heightCm!.toStringAsFixed(0)} cm' : '';
  final content = '${baby.name}\n$weight $height\n'
      '${now.day}/${now.month}/${now.year}';

  return StoryCard(
    id: 'birthday_$ageInDays',
    babyId: baby.id,
    userId: userId,
    type: 'birthday',
    titleVi: title,
    contentVi: content,
    theme: theme,
    cardDate: now,
    createdAt: now,
  );
}

const milestoneCards = {
  1: ('Ngày đầu tiên 🎉', 'blossom'),
  7: ('Tròn 1 tuần 🎉', 'lavender'),
  30: ('Tròn 1 tháng 🎉', 'blossom'),
  60: ('Tròn 2 tháng 🎉', 'lavender'),
  90: ('Tròn 3 tháng 🎉', 'mint'),
  100: ('100 ngày tuổi 🎉', 'gold'),
  180: ('Tròn 6 tháng 🎉', 'blossom'),
  270: ('Tròn 9 tháng 🎉', 'lavender'),
  365: ('Tròn 1 tuổi 🎉', 'gold'),
};
