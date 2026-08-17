import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/future_letter.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';

final _fs = FirebaseFirestore.instance;

CollectionReference<Map<String, dynamic>> _lettersCol(
        String userId, String babyId) =>
    _fs
        .collection('users')
        .doc(userId)
        .collection('babies')
        .doc(babyId)
        .collection('futureLetters');

final futureLettersProvider = StreamProvider<List<FutureLetter>>((ref) {
  final user = ref.watch(currentUserProvider);
  final baby = ref.watch(activeBabyProvider);
  if (user == null || baby == null) return Stream.value(const []);
  return _lettersCol(user.uid, baby.id)
      .orderBy('unlockDate')
      .snapshots()
      .map((s) => s.docs.map(FutureLetter.fromFirestore).toList());
});

Future<void> saveLetter(
        String userId, String babyId, FutureLetter letter) =>
    _lettersCol(userId, babyId).doc(letter.id).set(letter.toFirestore());

Future<void> deleteLetter(
        String userId, String babyId, String letterId) =>
    _lettersCol(userId, babyId).doc(letterId).delete();

Future<void> markLetterOpened(
    String userId, String babyId, String letterId) =>
    _lettersCol(userId, babyId).doc(letterId).update({
      'isOpened': true,
      'openedAt': Timestamp.fromDate(DateTime.now()),
    });
