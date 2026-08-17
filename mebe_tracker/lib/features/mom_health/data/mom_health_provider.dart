import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/auth_provider.dart';
import 'mom_health_entry.dart';

CollectionReference<Map<String, dynamic>> _momHealthCol(String userId) =>
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('mom_health');

final momHealthEntriesProvider =
    StreamProvider<List<MomHealthEntry>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return _momHealthCol(user.uid)
      .orderBy('date', descending: true)
      .limit(30)
      .snapshots()
      .map((s) => s.docs.map(MomHealthEntry.fromFirestore).toList());
});

final todayMomHealthProvider = Provider<MomHealthEntry?>((ref) {
  final entries = ref.watch(momHealthEntriesProvider).value;
  if (entries == null) return null;
  final today = DateTime.now();
  return entries.where((e) {
    return e.date.year == today.year &&
        e.date.month == today.month &&
        e.date.day == today.day;
  }).firstOrNull;
});

Future<void> saveMomHealthEntry(User user, MomHealthEntry entry) async {
  await _momHealthCol(user.uid)
      .doc(entry.dateKey)
      .set(entry.toFirestore(), SetOptions(merge: true));
}
