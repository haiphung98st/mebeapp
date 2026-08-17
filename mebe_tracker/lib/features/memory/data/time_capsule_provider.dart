import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/time_capsule.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';

final _fs = FirebaseFirestore.instance;

CollectionReference<Map<String, dynamic>> _capsulesCol(
        String userId, String babyId) =>
    _fs
        .collection('users')
        .doc(userId)
        .collection('babies')
        .doc(babyId)
        .collection('timeCapsules');

final timeCapsulesProvider = StreamProvider<List<TimeCapsule>>((ref) {
  final user = ref.watch(currentUserProvider);
  final baby = ref.watch(activeBabyProvider);
  if (user == null || baby == null) return Stream.value(const []);
  return _capsulesCol(user.uid, baby.id)
      .orderBy('unlockDate')
      .snapshots()
      .map((s) => s.docs.map(TimeCapsule.fromFirestore).toList());
});

Future<void> saveCapsule(
        String userId, String babyId, TimeCapsule capsule) =>
    _capsulesCol(userId, babyId)
        .doc(capsule.id)
        .set(capsule.toFirestore());

Future<void> addItemToCapsule(String userId, String babyId,
    String capsuleId, CapsuleItem item) async {
  final ref = _capsulesCol(userId, babyId).doc(capsuleId);
  await ref.update({
    'items': FieldValue.arrayUnion([item.toMap()]),
  });
}

Future<void> deleteCapsule(
        String userId, String babyId, String capsuleId) =>
    _capsulesCol(userId, babyId).doc(capsuleId).delete();

Future<void> markCapsuleOpened(
    String userId, String babyId, String capsuleId) =>
    _capsulesCol(userId, babyId).doc(capsuleId).update({
      'isOpened': true,
      'openedAt': Timestamp.fromDate(DateTime.now()),
    });
