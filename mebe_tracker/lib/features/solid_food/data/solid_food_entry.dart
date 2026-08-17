import 'package:cloud_firestore/cloud_firestore.dart';

enum FoodReaction { none, mild, severe }

class SolidFoodEntry {
  const SolidFoodEntry({
    required this.id,
    required this.userId,
    required this.babyId,
    required this.foodId,
    required this.foodName,
    required this.givenAt,
    this.amountGrams,
    this.reaction = FoodReaction.none,
    this.notes,
  });

  final String id;
  final String userId;
  final String babyId;
  final String foodId;
  final String foodName;
  final DateTime givenAt;
  final double? amountGrams;
  final FoodReaction reaction;
  final String? notes;

  factory SolidFoodEntry.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return SolidFoodEntry(
      id: doc.id,
      userId: d['userId'] as String,
      babyId: d['babyId'] as String,
      foodId: d['foodId'] as String,
      foodName: d['foodName'] as String,
      givenAt: (d['givenAt'] as Timestamp).toDate(),
      amountGrams: d['amountGrams'] != null
          ? (d['amountGrams'] as num).toDouble()
          : null,
      reaction:
          FoodReaction.values.byName(d['reaction'] as String? ?? 'none'),
      notes: d['notes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'babyId': babyId,
        'foodId': foodId,
        'foodName': foodName,
        'givenAt': Timestamp.fromDate(givenAt),
        if (amountGrams != null) 'amountGrams': amountGrams,
        'reaction': reaction.name,
        if (notes != null) 'notes': notes,
      };
}
