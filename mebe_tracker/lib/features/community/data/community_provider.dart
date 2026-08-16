import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';
import 'community_message.dart';

// The Firestore collection at root level: communities/{communityId}/messages
final FirebaseFirestore _fs = FirebaseFirestore.instance;

CollectionReference<Map<String, dynamic>> _messagesCol(String communityId) =>
    _fs.collection('communities').doc(communityId).collection('messages');

// Derive the community key from the baby's date of birth
final communityKeyProvider = Provider<String?>((ref) {
  final baby = ref.watch(activeBabyProvider);
  if (baby == null) return null;
  return communityKeyForDate(baby.dateOfBirth);
});

// Stream of messages for the baby's community group (latest 100, ordered by time)
final communityMessagesProvider = StreamProvider<List<CommunityMessage>>((ref) {
  final key = ref.watch(communityKeyProvider);
  if (key == null) return Stream.value(const []);
  return _messagesCol(key)
      .orderBy('createdAt', descending: false)
      .limitToLast(100)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => CommunityMessage.fromFirestore(d))
          .toList());
});

// Stable anonymous display name stored per user+community in local prefs via memory
final _anonymousNames = <String, String>{};

String _anonymousName(String userId, String communityId) {
  final key = '$userId-$communityId';
  return _anonymousNames.putIfAbsent(key, () {
    final n = Random().nextInt(9000) + 1000;
    return 'Mẹ $n';
  });
}

class CommunityNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> sendMessage(String text) async {
    final user = ref.read(currentUserProvider);
    final key = ref.read(communityKeyProvider);
    if (user == null || key == null || text.trim().isEmpty) return;

    final displayName = _anonymousName(user.uid, key);
    final doc = _messagesCol(key).doc();
    final msg = CommunityMessage(
      id: doc.id,
      communityId: key,
      userId: user.uid,
      displayName: displayName,
      text: text.trim(),
      createdAt: DateTime.now(),
    );
    await doc.set(msg.toFirestore());
  }
}

final communityNotifierProvider =
    NotifierProvider<CommunityNotifier, void>(CommunityNotifier.new);

// Member count estimate: how many distinct users in this community
final communityMemberCountProvider = FutureProvider<int>((ref) async {
  final key = ref.watch(communityKeyProvider);
  if (key == null) return 0;
  final snap = await _messagesCol(key).get();
  final uniqueUsers = snap.docs.map((d) => d.data()['userId']).toSet();
  return uniqueUsers.length;
});
