import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/family_member.dart';

/// Manages family member invites stored at `users/{userId}/familyMembers/{id}`.
class FamilySharingService {
  FamilySharingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _members(String userId) =>
      _firestore.collection('users').doc(userId).collection('familyMembers');

  Future<void> inviteByEmail(String userId, String email) {
    final member = FamilyMember(
      id: '',
      email: email,
      role: 'viewer',
      status: FamilyMemberStatus.pending,
      invitedAt: DateTime.now(),
    );
    return _members(userId).add(member.toFirestore());
  }

  Future<void> revoke(String userId, String memberId) => _members(userId).doc(memberId).delete();

  Stream<List<FamilyMember>> watchMembers(String userId) => _members(userId)
      .orderBy('invitedAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(FamilyMember.fromFirestore).toList());
}
