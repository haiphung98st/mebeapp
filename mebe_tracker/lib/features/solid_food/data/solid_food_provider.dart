import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';
import 'solid_food_entry.dart';

CollectionReference<Map<String, dynamic>> _solidFoodCol(
        String userId, String babyId) =>
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('babies')
        .doc(babyId)
        .collection('solid_foods');

final solidFoodEntriesProvider =
    StreamProvider<List<SolidFoodEntry>>((ref) {
  final user = ref.watch(currentUserProvider);
  final baby = ref.watch(activeBabyProvider);
  if (user == null || baby == null) return Stream.value([]);
  return _solidFoodCol(user.uid, baby.id)
      .orderBy('givenAt', descending: true)
      .limit(200)
      .snapshots()
      .map((s) => s.docs.map(SolidFoodEntry.fromFirestore).toList());
});

/// Set of food IDs that the baby has tried at least once with no severe reaction.
final triedFoodsProvider = Provider<Set<String>>((ref) {
  final entries = ref.watch(solidFoodEntriesProvider).value ?? [];
  return entries
      .where((e) => e.reaction != FoodReaction.severe)
      .map((e) => e.foodId)
      .toSet();
});
